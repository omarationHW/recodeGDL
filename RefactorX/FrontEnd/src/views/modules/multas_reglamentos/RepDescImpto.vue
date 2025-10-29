<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div><div class="module-view-info"><h1>Reporte Descuento de Impuesto</h1><p>Generación de reporte</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row"><div class="form-group"><label class="municipal-form-label">Ejercicio</label><input class="municipal-form-control" type="number" v-model.number="filters.ejercicio" /></div></div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="generar"><font-awesome-icon icon="print" /> Generar</button></div>
      </div></div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const BASE_DB = 'INFORMIX'
const OP_REPORTE = 'RECAUDADORA_REP_DESC_IMPTO' // TODO confirmar
const { loading, execute } = useApi()
const filters = ref({ ejercicio: new Date().getFullYear() })
async function generar(){ try{ await execute(OP_REPORTE, BASE_DB, [ { name:'ejercicio', type:'I', value: Number(filters.value.ejercicio||0) } ]) }catch(e){} }
</script>

