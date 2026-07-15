<template>
  <div class="grid-root">
    <!-- Header -->
    <div class="grid-header">
      <div class="grid-row header">
        <div v-for="col in columns" :key="col.key" class="grid-cell header-cell">
          {{ col.title }}
        </div>
      </div>
    </div>

    <!-- Body (simple non-virtual rendering for scaffold) -->
    <div class="grid-body">
      <div v-for="(row, rIdx) in rowData" :key="row[rowKey] || rIdx" class="grid-row">
        <div v-for="col in columns" :key="col.key" class="grid-cell">
          {{ row[col.key] }}
        </div>
      </div>
    </div>

    <!-- Footer / status -->
    <div class="grid-footer">
      <small>Rows: {{ rowData.length }}</small>
    </div>
  </div>
</template>

<script lang="ts">
import { defineComponent, onMounted, ref, toRefs } from 'vue'
import type { ColumnDef, RowData } from '../types'

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

    const internalApi = ref({})

    onMounted(() => {
      // Expose a minimal API for now
      internalApi.value = {
        getSelectedRows: () => [],
        setColumnVisible: (key: string, visible: boolean) => {
          console.log('setColumnVisible', key, visible)
        }
      }
      emit('ready', internalApi.value)
    })

    return { columns, rowData, rowKey }
  }
})
</script>

<style scoped>
.grid-root { border: 1px solid #ddd; background: #fff }
.grid-header { background: #f1f5f9; border-bottom: 1px solid #e5e7eb }
.grid-row { display: flex }
.grid-cell { padding: 8px 12px; border-right: 1px solid #eee; min-width: 80px }
.header-cell { font-weight: 600 }
.grid-body { max-height: 60vh; overflow: auto }
.grid-footer { padding: 8px 12px; border-top: 1px solid #eee; background: #fafafa }
</style>
