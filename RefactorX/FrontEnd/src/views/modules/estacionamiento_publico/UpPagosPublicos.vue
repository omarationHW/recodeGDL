<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="arrow-up-right-dots" /></div>
      <div class="module-view-info">
        <h1>Actualizar Pagos — Estacionamientos</h1>
        <p>Actualiza fecha de baja/pago del folio</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" :disabled="loading" @click="actualizar"><font-awesome-icon icon="save" /> Actualizar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Año (aso)</label><input type="number" class="municipal-form-control" v-model.number="form.alo" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio</label><input type="number" class="municipal-form-control" v-model.number="form.folio" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Baja</label><input type="date" class="municipal-form-control" v-model="form.fecbaj" /></div>
          </div>
          <div v-if="loading" class="spinner-border" role="status"></div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import apiService from '@/services/apiService'

const form = reactive({ alo: '', folio: '', fecbaj: '' })
const loading = ref(false)
const message = ref('')

async function actualizar() {
  loading.value = true
  message.value = ''
  try {
    const params = [
      { nombre: 'p_alo', valor: form.alo, tipo: 'integer' },
      { nombre: 'p_folio', valor: form.folio, tipo: 'integer' },
      { nombre: 'p_fecbaj', valor: form.fecbaj, tipo: 'string' }
    ]
    const resp = await apiService.execute('sp_up_pagos_update', 'estacionamiento_publico', params)
    message.value = resp?.message || (resp?.data?.result ? 'Actualización realizada' : 'Sin cambios')
  } catch (e) {
    message.value = e.message || 'Error al actualizar'
  } finally {
    loading.value = false
  }
}
</script>

