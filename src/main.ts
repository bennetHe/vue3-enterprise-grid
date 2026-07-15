import { createApp } from 'vue'
import App from './App.vue'

// ag-Grid module registration (robust / defensive)
;(async function registerAgGridModules() {
  try {
    // Try dynamic import to handle different package export shapes across versions
    const mod = await import('ag-grid-community')
    const ModuleRegistry = (mod as any).ModuleRegistry || (mod as any).module ? (mod as any).module.ModuleRegistry : undefined
    const AllCommunityModules = (mod as any).AllCommunityModules || (mod as any).allCommunityModules || (mod as any).AllModules

    if (ModuleRegistry && AllCommunityModules) {
      try {
        ModuleRegistry.registerModules(AllCommunityModules)
        // console.log('ag-Grid community modules registered')
      } catch (e) {
        console.warn('ag-Grid module registration attempted but failed:', e)
      }
    } else {
      // If exports are not present, try named import fallback (rare)
      try {
        // eslint-disable-next-line @typescript-eslint/no-var-requires
        const req = require('ag-grid-community')
        if (req && (req as any).ModuleRegistry && (req as any).AllCommunityModules) {
          ;(req as any).ModuleRegistry.registerModules((req as any).AllCommunityModules)
        }
      } catch (e) {
        // ignore - not fatal
        console.warn('ag-Grid module registration fallback failed (non-fatal)')
      }
    }
  } catch (err) {
    // Non-fatal: grid can still work with default community modules in many cases
    console.warn('ag-Grid dynamic import failed (non-fatal):', err)
  }
})()

import './styles.css'

createApp(App).mount('#app')
