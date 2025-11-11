<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="keyboard" /></div><div class="module-view-info"><h1>Captura de Diferencias</h1><p>Registro de diferencias</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group full-width"><label class="municipal-form-label">Datos (JSON)</label><textarea class="municipal-form-control" rows="8" v-model="jsonPayload"></textarea></div>
        </div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading || !jsonPayload" @click="guardar"><font-awesome-icon icon="save" /> Guardar</button></div>
      </div></div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const BASE_DB = 'multas_reglamentos'
const OP_SAVE='RECAUDADORA_CAPTURA_DIF' // TODO confirmar
const { loading, execute } = useApi()
const jsonPayload = ref('')
async function guardar(){ try{ await execute(OP_SAVE, BASE_DB, [ { name:'datos', type:'C', value: jsonPayload.value } ]) }catch(e){} }
</script>

