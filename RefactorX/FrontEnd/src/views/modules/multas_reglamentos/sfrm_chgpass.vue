<template>
  <div class="module-view module-layout">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="key" /></div>
      <div class="module-view-info"><h1>Cambio de Password</h1></div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Usuario</label>
              <input class="municipal-form-control" v-model="form.usuario"/>
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Nuevo Password</label>
              <input class="municipal-form-control" v-model="form.password" type="password"/>
            </div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="cambiar">Cambiar</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '@/composables/useApi'

const { loading, execute } = useApi()
const BASE_DB = 'INFORMIX'
const OP = 'RECAUDADORA_SFRM_CHGPASS'
const form = ref({ usuario:'', password:'' })

async function cambiar(){
  try {
    await execute(OP, BASE_DB, [
      { name:'usuario', type:'C', value:String(form.value.usuario||'') },
      { name:'password', type:'C', value:String(form.value.password||'') }
    ])
  } catch (e) {}
}
</script>
