<template>
  <div>
    <h1>Vue3 Enterprise Grid — Scaffold</h1>
    <p>Milestone0: TypeScript + Vite scaffold with a minimal DataGrid skeleton.</p>

    <div style="margin: 12px 0">
      <button @click="reloadData">Replace data (demo)</button>
    </div>

    <DataGrid
      ref="grid"
      :columns="columns"
      :rowData="rows"
      @ready="onGridReady"
    />
  </div>
</template>

<script lang="ts">
import { defineComponent, ref } from 'vue'
import DataGrid from './components/DataGrid.vue'
import type { ColumnDef, RowData } from './types'

export default defineComponent({
  name: 'App',
  components: { DataGrid },
  setup() {
    const rows = ref<RowData[]>([
      { id: 1, country: 'China', year: 2020, value: 100, name: 'A' },
      { id: 2, country: 'China', year: 2021, value: 120, name: 'B' },
      { id: 3, country: 'USA', year: 2020, value: 200, name: 'C' },
      { id: 4, country: 'USA', year: 2021, value: 220, name: 'D' }
    ])

    const columns = ref<ColumnDef[]>([
      { key: 'id', title: 'ID', width: 80 },
      { key: 'country', title: 'Country' },
      { key: 'year', title: 'Year' },
      { key: 'value', title: 'Value' },
      { key: 'name', title: 'Name' }
    ])

    function onGridReady(api: unknown) {
      console.log('grid ready', api)
    }

    function reloadData() {
      rows.value = rows.value.concat({ id: Date.now(), country: 'Germany', year: 2022, value: 88, name: 'E' })
    }

    return { rows, columns, onGridReady, reloadData }
  }
})
</script>
