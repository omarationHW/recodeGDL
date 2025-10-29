<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="calendar" /></div><div class="module-view-info"><h1>Periodo Inicial</h1><p>Configuración y consulta</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group"><label class="municipal-form-label">Ejercicio</label><input class="municipal-form-control" type="number" v-model.number="filters.ejercicio" /></div>
        </div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="consultar"><font-awesome-icon icon="search" /> Consultar</button></div>
      </div></div>
      <div class="municipal-card"><div class="municipal-card-header"><h5>Parámetros</h5><div v-if="loading" class="spinner-border"></div></div>
        <div class="municipal-card-body" v-if="!loading">
          <pre class="text-muted" style="white-space: pre-wrap;">{{ JSON.stringify(data, null, 2) }}</pre>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const BASE_DB = 'INFORMIX'
const OP_GET = 'RECAUDADORA_PERIODO_INICIAL' // TODO confirmar
const { loading, execute } = useApi()
const filters = ref({ ejercicio: new Date().getFullYear() })
const data = ref(null)
async function consultar(){ const params=[{name:'ejercicio',type:'I',value:Number(filters.value.ejercicio||0)}]; try{ data.value = await execute(OP_GET, BASE_DB, params) }catch(e){ data.value=null } }
consultar()
</script>

