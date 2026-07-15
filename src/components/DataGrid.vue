<template>
  <div class="grid-root">
    <!-- Header -->
    <div class="grid-header">
      <div class="grid-row header">
        <div v-for="col in visibleColumns" :key="col.key" :style="{ minWidth: (col.width ? col.width + 'px' : '80px') }" class="grid-cell header-cell" @click="onHeaderClick(col)">
          {{ col.title ?? col.key }}
          <span style="float:right; font-weight:200; font-size:12px; opacity:0.7">{{ sortIndicator(col.key) }}</span>
        </div>
      </div>
    </div>

    <!-- Body (non-virtual rendering for MVP) -->
    <div class="grid-body">
      <div v-for="(row, rIdx) in displayedRows" :key="row[rowKey] || rIdx" class="grid-row" :class="{ 'row-selected': isRowSelected(row) }" @click="onRowClick($event, row)">
        <div v-for="col in visibleColumns" :key="col.key" class="grid-cell">
          {{ row[col.key] }}
        </div>
      </div>
    </div>

    <!-- Footer / status -->
    <div class="grid-footer">
      <small>Rows: {{ displayedRows.length }} (all: {{ rowData.length }})</small>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, toRefs, reactive, computed } from 'vue'
import type { ColumnDef, RowData } from '../types'
import { DataModel } from '../core/DataModel'
import { ColumnModel } from '../core/ColumnModel'

export default defineComponent({
  name: 'DataGrid',
  props: {
    columns: { type: Array as () => ColumnDef[], required: true },
    rowData: { type: Array as () => RowData[], required: true },
    rowKey: { type: String, default: 'id' }
  },
  emits: ['ready'],
  setup(props, { emit }) {
    const { columns, rowData, rowKey } = toRefs(props)

    // internal models
    const dataModel = new DataModel(rowData.value || [])
    const columnModel = new ColumnModel((columns.value || []).map(c => ({ key: c.key, width: c.width, visible: c.visible })))

    // selection state
    const selectedIds = reactive(new Set<any>())

    // sorting state
    const sortState = ref<{ key?: string, dir?: 'asc'|'desc' } | null>(null)

    onMounted(() => {
      // subscribe to model changes
      dataModel.on('change', () => {
        // for now we simply cause a reactive update by replacing displayedRows via computed reading dataModel
      })

      // expose API
      const api = {
        getSelectedRows: () => {
          const all = dataModel.getAll()
          return all.filter(r => selectedIds.has(r[rowKey.value]))
        },
        setColumnVisible: (key: string, visible: boolean) => {
          columnModel.setVisibility(key, visible)
        },
        applyTransaction: (tx: any) => dataModel.applyTransaction(tx),
        setSort: (key: string | null, dir?: 'asc'|'desc') => {
          if (!key) { sortState.value = null; return }
          sortState.value = { key: key as string, dir: dir || 'asc' }
        }
      }

      emit('ready', api)
    })

    // computed visible columns by columnModel
    const visibleColumns = computed(() => {
      const state = columnModel.getAll()
      // map to original column defs to carry title
      return state.filter(s => s.visible).map(s => {
        const original = columns.value.find(c => c.key === s.key) || { key: s.key, title: s.key }
        return { key: s.key, title: original.title, width: s.width }
      })
    })

    // data source: read from prop rowData but keep DataModel in sync
    // If parent replaces rowData prop, update DataModel
    const replaceData = (newRows: RowData[]) => {
      // naive replacement
      dataModel.applyTransaction({ remove: dataModel.getAll().map(r => ({ id: r.id })), add: newRows })
    }

    // displayedRows applies simple sorting
    const displayedRows = computed(() => {
      let rows = dataModel.getAll()
      if (sortState.value && sortState.value.key) {
        const key = sortState.value.key
        const dir = sortState.value.dir === 'asc' ? 1 : -1
        rows = rows.slice().sort((a,b) => {
          const va = a[key]; const vb = b[key]
          if (va == null && vb == null) return 0
          if (va == null) return -1 * dir
          if (vb == null) return 1 * dir
          if (va < vb) return -1 * dir
          if (va > vb) return 1 * dir
          return 0
        })
      }
      return rows
    })

    function onRowClick(e: MouseEvent, row: RowData) {
      const id = row[rowKey.value]
      if (e.ctrlKey || e.metaKey) {
        // toggle
        if (selectedIds.has(id)) selectedIds.delete(id)
        else selectedIds.add(id)
      } else if ((e as any).shiftKey) {
        // TODO: range selection - for MVP treat as toggle
        selectedIds.add(id)
      } else {
        // single select
        selectedIds.clear()
        selectedIds.add(id)
      }
    }

    function isRowSelected(row: RowData) {
      return selectedIds.has(row[rowKey.value])
    }

    function onHeaderClick(col: any) {
      // toggle sort asc -> desc -> none
      if (!sortState.value || sortState.value.key !== col.key) {
        sortState.value = { key: col.key, dir: 'asc' }
      } else if (sortState.value.dir === 'asc') {
        sortState.value.dir = 'desc'
      } else {
        sortState.value = null
      }
    }

    function sortIndicator(key: string) {
      if (!sortState.value || sortState.value.key !== key) return ''
      return sortState.value.dir === 'asc' ? '↑' : '↓'
    }

    // Watch for incoming prop changes and sync models
    // (Simple equality checks for MVP)
    const prevRows = ref<RowData[] | null>(null)
    if (rowData.value) {
      // initialize DataModel rows if empty
      const existing = dataModel.getAll()
      if (existing.length === 0 && rowData.value.length) {
        dataModel.applyTransaction({ add: rowData.value })
      }
    }

    return {
      visibleColumns,
      displayedRows,
      onRowClick,
      isRowSelected,
      onHeaderClick,
      sortIndicator
    }
  }
})
</script>

<style scoped>
.grid-root { border: 1px solid #ddd; background: #fff }
.grid-header { background: #f1f5f9; border-bottom: 1px solid #e5e7eb }
.grid-row { display: flex }
.grid-cell { padding: 8px 12px; border-right: 1px solid #eee; min-width: 80px }
.header-cell { font-weight: 600; user-select: none }
.grid-body { max-height: 60vh; overflow: auto }
.grid-footer { padding: 8px 12px; border-top: 1px solid #eee; background: #fafafa }
.row-selected { background: #e6f7ff }
</style>
