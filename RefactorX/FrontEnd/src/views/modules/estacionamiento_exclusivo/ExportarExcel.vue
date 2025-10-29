<template>
  <div class="module-view module-layout"><div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="file-excel" /></div><div class="module-view-info"><h1>Exportar a Excel</h1></div></div>
    <div class="module-view-content"><div class="municipal-card"><div class="municipal-card-body">
      <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="exportar">Exportar</button></div>
    </div></div>
  </div>
</template>
<script setup>
import { useApi } from '@/composables/useApi'
const { loading, execute } = useApi(); const BASE_DB='INFORMIX'; const OP='APREMIOSSVN_EXPORTAR_EXCEL'
async function exportar(){ try{ await execute(OP, BASE_DB, []) }catch(e){} }
</script>

