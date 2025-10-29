<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="ban" /></div><div class="module-view-info"><h1>Cancelaciones</h1><p>canc.vue</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row"><div class="form-group"><label class="municipal-form-label">Folio</label><input class="municipal-form-control" v-model.number="form.folio" type="number"/></div><div class="form-group"><label class="municipal-form-label">Año</label><input class="municipal-form-control" v-model.number="form.ejercicio" type="number"/></div></div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="cancelar"><font-awesome-icon icon="ban"/> Cancelar</button></div>
      </div></div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const BASE_DB='INFORMIX'
const OP_CANCEL='RECAUDADORA_CANC' // TODO confirmar
const { loading, execute } = useApi()
const form=ref({ folio:null, ejercicio:new Date().getFullYear() })
async function cancelar(){ const params=[{name:'folio',type:'I',value:Number(form.value.folio||0)},{name:'ejercicio',type:'I',value:Number(form.value.ejercicio||0)}]; try{ await execute(OP_CANCEL, BASE_DB, params) }catch(e){} }
</script>

