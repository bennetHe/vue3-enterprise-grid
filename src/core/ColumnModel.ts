// Minimal ColumnModel skeleton
export class ColumnModel {
  private cols: any[] = []
  constructor(cols: any[] = []) { this.cols = cols }

  getAll() { return this.cols }

  setVisibility(key: string, visible: boolean) {
    const c = this.cols.find((x:any) => x.key === key)
    if (c) c.visible = visible
  }
}
