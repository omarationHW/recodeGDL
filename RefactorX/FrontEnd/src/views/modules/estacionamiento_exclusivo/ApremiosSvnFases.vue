<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="timeline" /></div>
      <div class="module-view-info"><h1>Control de Fases</h1><p>Requerimiento → Embargo → Remate → Adjudicación</p></div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Expediente</label><input class="municipal-form-control" v-model="form.expediente" /></div>
            <div class="form-group"><label class="municipal-form-label">Nueva Fase</label>
              <select class="municipal-form-control" v-model="form.fase">
                <option value="REQUERIMIENTO">REQUERIMIENTO</option>
                <option value="EMBARGO">EMBARGO</option>
                <option value="REMATE">REMATE</option>
                <option value="ADJUDICACION">ADJUDICACIÓN</option>
              </select>
            </div>
          </div>
          <div class="button-group"><button class="btn-municipal-primary" :disabled="loading || !form.expediente || !form.fase" @click="cambiarFase"><font-awesome-icon icon="shuffle" /> Cambiar Fase</button></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const BASE_DB = 'INFORMIX'
const OP_CAMBIAR_FASE = 'APREMIOSSVN_CAMBIAR_FASE'
const { loading, execute } = useApi()

const form = ref({ expediente: '', fase: 'REQUERIMIENTO' })

async function cambiarFase(){
  const params = [
    { name: 'expediente', type: 'C', value: String(form.value.expediente || '') },
    { name: 'fase', type: 'C', value: String(form.value.fase || '') }
  ]
  try { await execute(OP_CAMBIAR_FASE, BASE_DB, params) } catch(e) {}
}
</script>

