// Core types used across the grid (minimal for scaffold)
export type RowData = Record<string, any>

export interface ColumnDef {
  key: string
  title?: string
  width?: number
  visible?: boolean
}
