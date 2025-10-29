<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div><div class="module-view-info"><h1>Extractos (Reporte)</h1><p>Generación de extractos</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row"><div class="form-group"><label class="municipal-form-label">Cuenta</label><input class="municipal-form-control" v-model="filters.cuenta"/></div></div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="generar"><font-awesome-icon icon="print"/> Generar</button></div>
      </div></div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const BASE_DB='INFORMIX'
const OP_REP='RECAUDADORA_EXTRACTOS_RPT' // TODO confirmar
const { loading, execute } = useApi()
const filters=ref({ cuenta:'' })
async function generar(){ const params=[{name:'clave_cuenta',type:'C',value:String(filters.value.cuenta||'')}]; try{ await execute(OP_REP, BASE_DB, params) }catch(e){} }
</script>

