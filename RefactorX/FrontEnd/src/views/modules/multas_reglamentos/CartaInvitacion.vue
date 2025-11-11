<template>
  <div class="module-view module-layout">
    <div class="module-view-header"><div class="module-view-icon"><font-awesome-icon icon="envelope" /></div><div class="module-view-info"><h1>Carta Invitación</h1><p>Generación de cartas</p></div></div>
    <div class="module-view-content">
      <div class="municipal-card"><div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group"><label class="municipal-form-label">Cuenta</label><input class="municipal-form-control" v-model="filters.cuenta"/></div>
          <div class="form-group"><label class="municipal-form-label">Ejercicio</label><input class="municipal-form-control" type="number" v-model.number="filters.ejercicio"/></div>
        </div>
        <div class="button-group"><button class="btn-municipal-primary" :disabled="loading" @click="generar"><font-awesome-icon icon="envelope-open-text" /> Generar</button></div>
      </div></div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'
const BASE_DB = 'multas_reglamentos'
const OP_GEN='RECAUDADORA_CARTA_INVITACION' // TODO confirmar
const { loading, execute } = useApi()
const filters=ref({ cuenta:'', ejercicio:new Date().getFullYear() })
async function generar(){ const params=[{name:'clave_cuenta',type:'C',value:String(filters.value.cuenta||'')},{name:'ejercicio',type:'I',value:Number(filters.value.ejercicio||0)}]; try{ await execute(OP_GEN, BASE_DB, params) }catch(e){} }
</script>

