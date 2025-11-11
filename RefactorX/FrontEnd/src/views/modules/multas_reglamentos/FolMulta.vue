<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="hashtag" /></div><div class="module-view-info"><h1>Folio de Multa</h1><p>Gestión de folios</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row"><div class="form-group"><label class="municipal-form-label">Cuenta</label><input class="municipal-form-control" v-model="form.clave_cuenta"/></div><div class="form-group"><label class="municipal-form-label">Año</label><input class="municipal-form-control" type="number" v-model.number="form.ejercicio"/></div></div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="generar"><font-awesome-icon icon="save"/> Generar Folio</button></div>
      </div></div>
      <div class="municipal-card"><div class="municipal-card-header"><h5>Resultado</h5></div><div class="municipal-card-body"><pre class="text-muted" style="white-space: pre-wrap;">{{ JSON.stringify(result,null,2) }}</pre></div></div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const BASE_DB = 'multas_reglamentos'
const OP_GEN='RECAUDADORA_FOL_MULTA' // TODO confirmar
const { loading, execute } = useApi()
const form=ref({ clave_cuenta:'', ejercicio:new Date().getFullYear() })
const result=ref(null)
async function generar(){ const params=[{name:'clave_cuenta',type:'C',value:String(form.value.clave_cuenta||'')},{name:'ejercicio',type:'I',value:Number(form.value.ejercicio||0)}]; try{ result.value = await execute(OP_GEN, BASE_DB, params) }catch(e){ result.value={ error:e?.message||'Error' } } }
</script>

