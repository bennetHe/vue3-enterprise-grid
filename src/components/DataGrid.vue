<template>
  <div class="ag-theme-alpine" style="width:100%; height:60vh;">
    <ag-grid-vue
      ref="agRef"
      :columnDefs="columnDefs"
      :rowData="rowData"
      :defaultColDef="defaultColDef"
      :rowSelection="rowSelection"
      :animateRows="true"
      :suppressClickEdit="false"
      :suppressMenuHide="false"
      :getContextMenuItems="getContextMenuItems"
      @grid-ready="onGridReady"
    />
  </div>
</template>

<script lang="ts">
import { defineComponent, ref, onMounted, watch } from 'vue'
import { AgGridVue } from 'ag-grid-vue3'
import type { ColumnDef as AgColumnDef, GridApi, ColumnApi } from 'ag-grid-community'
import 'ag-grid-community/styles/ag-grid.css'
import 'ag-grid-community/styles/ag-theme-alpine.css'
import * as XLSX from 'xlsx'

// expose XLSX for potential integrations
if (typeof window !== 'undefined') (window as any).XLSX = XLSX

import type { ColumnDef, RowData } from '../types'

export default defineComponent({
  name: 'DataGrid',
  components: { AgGridVue },
  props: {
    columns: { type: Array as () => ColumnDef[], required: true },
    rowData: { type: Array as () => RowData[], required: true },
    rowKey: { type: String, default: 'id' }
  },
  emits: ['ready'],
  setup(props, { emit }) {
    const agRef = ref<any>(null)
    const gridApi = ref<GridApi | null>(null)
    const columnApi = ref<ColumnApi | null>(null)

    const columnDefs = ref<AgColumnDef[]>(props.columns.map(c => ({ field: c.key, headerName: c.title ?? c.key, hide: c.visible === false, width: c.width })))

    watch(() => props.columns, (nv) => {
      columnDefs.value = nv.map(c => ({ field: c.key, headerName: c.title ?? c.key, hide: c.visible === false, width: c.width }))
    }, { deep: true })

    watch(() => props.rowData, (nv) => {
      // when parent replaces rowData, set row data on grid
      if (gridApi.value) gridApi.value.setRowData(nv || [])
    })

    const defaultColDef = { resizable: true, sortable: true, filter: true }
    const rowSelection = 'multiple'

    function onGridReady(params: any) {
      gridApi.value = params.api
      columnApi.value = params.columnApi

      // expose simple api
      const api = {
        getSelectedRows: () => gridApi.value ? gridApi.value.getSelectedRows() : [],
        setColumnVisible: (key: string, visible: boolean) => columnApi.value && columnApi.value.setColumnVisible(key, visible),
        applyTransaction: (tx: any) => gridApi.value ? gridApi.value.applyTransaction(tx) : null,
        setSort: (key: string | null, dir?: 'asc'|'desc') => {
          if (!gridApi.value) return
          if (!key) { gridApi.value.setSortModel([]); return }
          gridApi.value.setSortModel([{ colId: key, sort: dir || 'asc' }])
        },
        exportCsv: (params = { fileName: 'export.csv' }) => gridApi.value && gridApi.value.exportDataAsCsv(params),
        exportXlsx: exportXlsx,
        copySelectedToClipboard: copySelectedToClipboard
      }

      emit('ready', api)
    }

    function getContextMenuItems(params: any) {
      const result = [
        'copy',
        'copyWithHeaders',
        'separator',
        {
          name: 'Export CSV',
          action: () => {
            if (gridApi.value) gridApi.value.exportDataAsCsv({ fileName: 'export.csv' })
          }
        },
        {
          name: 'Export XLSX',
          action: () => exportXlsx()
        },
        'separator',
        {
          name: 'Show Details',
          action: () => alert(JSON.stringify(params.node?.data || params.value))
        }
      ]
      return result
    }

    async function copySelectedToClipboard() {
      if (!gridApi.value) return
      const selected = gridApi.value.getSelectedRows()
      if (!selected || selected.length === 0) {
        // fallback to all displayed rows
        const rows: any[] = []
        gridApi.value.forEachNodeAfterFilterAndSort((node: any) => { if (node.data) rows.push(node.data) })
        const text = rows.map(r => Object.values(r).join('\t')).join('\n')
        try { await navigator.clipboard.writeText(text); alert('Copied visible rows to clipboard') } catch (e) { console.warn('clipboard failed', e) }
        return
      }
      const text = selected.map(r => Object.values(r).join('\t')).join('\n')
      try { await navigator.clipboard.writeText(text); alert('Copied selection to clipboard') } catch (e) { console.warn('clipboard failed', e) }
    }

    function exportXlsx() {
      if (!gridApi.value) return
      const rows: any[] = []
      gridApi.value.forEachNodeAfterFilterAndSort((node: any) => { if (node.data) rows.push(node.data) })
      if (!rows.length) { alert('No rows to export'); return }
      const ws = XLSX.utils.json_to_sheet(rows)
      const wb = XLSX.utils.book_new()
      XLSX.utils.book_append_sheet(wb, ws, 'Sheet1')
      XLSX.writeFile(wb, 'export.xlsx')
    }

    onMounted(() => {
      // nothing for now
    })

    return { agRef, columnDefs, defaultColDef, rowSelection, onGridReady, getContextMenuItems }
  }
})
</script>

<style scoped>
.ag-theme-alpine { border: 1px solid #e5e7eb; background: #fff }
</style>
