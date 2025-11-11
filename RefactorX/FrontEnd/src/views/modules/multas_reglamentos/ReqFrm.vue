<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="file-invoice" /></div><div class="module-view-info"><h1>Requerimiento (Formulario)</h1><p>Captura y actualización</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group"><label class="municipal-form-label">Cuenta</label><input class="municipal-form-control" v-model="form.clave_cuenta" /></div>
          <div class="form-group"><label class="municipal-form-label">Folio</label><input class="municipal-form-control" type="number" v-model.number="form.folio" /></div>
          <div class="form-group"><label class="municipal-form-label">Año</label><input class="municipal-form-control" type="number" v-model.number="form.ejercicio" /></div>
        </div>
        <div class="button-group">
          <button class="btn-municipal-primary" :disabled="loading" @click="guardar"><font-awesome-icon icon="save" /> Guardar</button>
        </div>
      </div></div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const BASE_DB = 'multas_reglamentos'
const OP_SAVE = 'RECAUDADORA_REQ_FRM_SAVE' // TODO confirmar
const { loading, execute } = useApi()
const form = ref({ clave_cuenta: '', folio: null, ejercicio: new Date().getFullYear() })
async function guardar(){ try{ await execute(OP_SAVE, BASE_DB, [ { name:'registro', type:'C', value: JSON.stringify(form.value) } ]) }catch(e){} }
</script>

