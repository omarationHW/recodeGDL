<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="user-xmark" /></div>
      <div class="module-view-info">
        <h1>Bajas — Estacionamientos Públicos</h1>
        <p>Procesamiento de bajas con motivo</p>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Licencia</label><input class="municipal-form-control" v-model="form.numlic" /></div>
            <div class="form-group full-width"><label class="municipal-form-label">Motivo</label><input class="municipal-form-control" v-model="form.motivo" /></div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="darBaja"><font-awesome-icon icon="ban" /> Dar de baja</button>
          </div>
          <div v-if="loading" class="spinner-border" role="status"><span class="visualmente-hidden">Procesando...</span></div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import apiService from '@/services/apiService'

const form = reactive({ numlic: '', motivo: '' })
const loading = ref(false)
const message = ref('')

async function darBaja() {
  loading.value = true
  message.value = ''
  try {
    // Pendiente SP específico de bajas públicas
    const parametros = Object.entries(form).map(([nombre, valor]) => ({ nombre, valor, tipo: 'string' }))
    const resp = await apiService.execute('sp_sfrm_baja_pub', 'estacionamiento_publico', parametros)
    message.value = resp?.message || (resp?.success ? 'Baja registrada' : 'No se pudo procesar')
  } catch (e) {
    message.value = e.message || 'Error en la operación'
  } finally {
    loading.value = false
  }
}
</script>

