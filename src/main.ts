import { createApp } from 'vue'
import App from './App.vue'

// ag-Grid module registration (ensure community modules are available)
import { ModuleRegistry, AllCommunityModules } from 'ag-grid-community'
ModuleRegistry.registerModules(AllCommunityModules)

import './styles.css'

createApp(App).mount('#app')
