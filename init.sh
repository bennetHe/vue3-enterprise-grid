#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <git-remote-url> [branch-name]"
  echo "Example: $0 https://github.com/bennetHe/vue3-enterprise-grid.git main"
  exit 1
fi

REMOTE_URL="$1"
BRANCH="${2:-main}"

echo "Initializing project in $(pwd)"
echo "Remote: $REMOTE_URL"
echo "Branch: $BRANCH"

# Create directories
mkdir -p src/components src/core .github/workflows

# package.json
cat > package.json <<'EOF'
{
  "name": "vue3-enterprise-grid",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "type-check": "tsc --noEmit",
    "test": "vitest"
  },
  "dependencies": {
    "vue": "^3.3.0"
  },
  "devDependencies": {
    "@vitejs/plugin-vue": "^4.0.0",
    "typescript": "^5.1.6",
    "vite": "^5.0.0",
    "vitest": "^1.0.0"
  }
}
EOF

# README.md
cat > README.md <<'EOF'
# Vue3 Enterprise Grid (clean-room implementation)

This repository is the clean‑room TypeScript + Vue 3 scaffold for a community implementation of enterprise-grade grid features (right-click menu, grouping/aggregation, column visibility, advanced filters, range selection & clipboard, XLSX export) — intentionally not using or bundling any ag‑Grid Enterprise code.

Status: initial scaffold (milestone0)

Quick start

1. Install dependencies

   npm install

2. Start dev server

   npm run dev

3. Open http://localhost:5173

Goals for milestone0

- TypeScript + Vite + Vue3 scaffold
- Basic DataGrid component skeleton (API surface & core modules)
- README, MIT license, CI, minimal demo

License: MIT
EOF

# LICENSE
cat > LICENSE <<'EOF'
MIT License

Copyright (c) 2026 bennetHe

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# vite.config.ts
cat > vite.config.ts <<'EOF'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    port: 5173
  }
})
EOF

# tsconfig.json
cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2020",
    "useDefineForClassFields": true,
    "module": "ESNext",
    "moduleResolution": "Node",
    "lib": ["ESNext", "DOM"],
    "jsx": "preserve",
    "sourceMap": true,
    "strict": true,
    "resolveJsonModule": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "types": ["vitest/globals"]
  },
  "include": ["src/**/*.ts", "src/**/*.d.ts", "src/**/*.vue"],
  "references": []
}
EOF

# .gitignore
cat > .gitignore <<'EOF'
node_modules
dist
.env
.vscode
.idea
.DS_Store
coverage
EOF

# .github/workflows/ci.yml
cat > .github/workflows/ci.yml <<'EOF'
name: CI
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Use Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 18
      - name: Install
        run: npm ci
      - name: Type check
        run: npm run type-check
      - name: Build
        run: npm run build
EOF

# src/main.ts
cat > src/main.ts <<'EOF'
import { createApp } from 'vue'
import App from './App.vue'

import './styles.css'

createApp(App).mount('#app')
EOF

# src/styles.css
cat > src/styles.css <<'EOF'
/* basic styles for scaffold */
html, body, #app {
  height: 100%;
  margin: 0;
}
body {
  font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial;
  padding: 16px;
  background: #f7f8fa;
}

button { cursor: pointer }
EOF

# src/App.vue
cat > src/App.vue <<'EOF'
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
EOF

# src/components/DataGrid.vue
cat > src/components/DataGrid.vue <<'EOF'
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
EOF

# src/types.ts
cat > src/types.ts <<'EOF'
// Core types used across the grid (minimal for scaffold)
export type RowData = Record<string, any>

export interface ColumnDef {
  key: string
  title?: string
  width?: number
  visible?: boolean
}
EOF

# src/core/DataModel.ts
cat > src/core/DataModel.ts <<'EOF'
// Minimal DataModel skeleton (clean-room implementation placeholder)
export class DataModel {
  private rows: any[] = []

  constructor(initial: any[] = []) {
    this.rows = initial.slice()
  }

  getAll() { return this.rows }

  getById(id: any) { return this.rows.find(r => r.id === id) }

  applyTransaction(tx: { add?: any[], update?: any[], remove?: any[] }) {
    // TODO: implement transactional updates with diffs and events
    if (tx.add) this.rows.push(...tx.add)
    if (tx.update) tx.update.forEach(u => {
      const idx = this.rows.findIndex(r => r.id === u.id)
      if (idx >= 0) this.rows[idx] = { ...this.rows[idx], ...u }
    })
    if (tx.remove) tx.remove.forEach(rm => {
      const idx = this.rows.findIndex(r => r.id === rm.id)
      if (idx >= 0) this.rows.splice(idx, 1)
    })
  }
}
EOF

# src/core/ColumnModel.ts
cat > src/core/ColumnModel.ts <<'EOF'
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
EOF

# Install dependencies
echo "Installing npm dependencies (this may take a few minutes)..."
npm install

# Initialize git if needed
if [ -d .git ]; then
  echo "Existing git repository detected."
else
  git init
  git checkout -b "$BRANCH"
fi

# Add remote if not set
if git remote get-url origin >/dev/null 2>&1; then
  echo "origin remote already exists: $(git remote get-url origin)"
else
  git remote add origin "$REMOTE_URL"
  echo "Added remote origin -> $REMOTE_URL"
fi

# Commit files
git add .
git commit -m "chore(scaffold): initial TypeScript + Vite scaffold for vue3-enterprise-grid (milestone0)" || true

echo ""
echo "Scaffold created and committed locally."
echo "To push to remote run:"
echo ""
echo "  git push -u origin $BRANCH"
echo ""
echo "Then install and run locally:"
echo ""
echo "  npm install"
echo "  npm run dev"
echo ""
echo "If you want me to push the code, ensure this machine has permission to push to the remote URL,"
echo "or push from your local environment (the above push command)."
echo ""
echo "Done."