<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-circle-plus" /></div>
      <div class="module-view-info">
        <h1>Alta de Folio de Adeudo</h1>
        <p>Insertar en ta14_folios_adeudo</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" :disabled="loading" @click="guardar"><font-awesome-icon icon="save" /> Guardar</button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Año</label><input type="number" class="municipal-form-control" v-model.number="f.axo" /></div>
            <div class="form-group"><label class="municipal-form-label">Folio</label><input type="number" class="municipal-form-control" v-model.number="f.folio" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha Folio</label><input type="date" class="municipal-form-control" v-model="f.fecha_folio" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Placa</label><input class="municipal-form-control" v-model="f.placa" /></div>
            <div class="form-group"><label class="municipal-form-label">Infracción</label><input type="number" class="municipal-form-control" v-model.number="f.infraccion" /></div>
            <div class="form-group"><label class="municipal-form-label">Estado</label><input type="number" class="municipal-form-control" v-model.number="f.estado" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Vigilante</label><input type="number" class="municipal-form-control" v-model.number="f.vigilante" /></div>
            <div class="form-group"><label class="municipal-form-label">Usuario Inicial</label><input type="number" class="municipal-form-control" v-model.number="f.usu_inicial" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Zona</label><input type="number" class="municipal-form-control" v-model.number="f.zona" /></div>
            <div class="form-group"><label class="municipal-form-label">Espacio</label><input type="number" class="municipal-form-control" v-model.number="f.espacio" /></div>
          </div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import apiService from '@/services/apiService'

const f = reactive({ axo: new Date().getFullYear(), folio: 0, fecha_folio: new Date().toISOString().substring(0,10), placa: '', infraccion: 0, estado: 0, vigilante: 0, usu_inicial: 0, zona: 0, espacio: 0 })
const loading = ref(false)
const message = ref('')

async function guardar() {
  loading.value = true
  message.value = ''
  try {
    const params = [
      { nombre: 'p_axo', valor: f.axo, tipo: 'integer' },
      { nombre: 'p_folio', valor: f.folio, tipo: 'integer' },
      { nombre: 'p_fecha_folio', valor: f.fecha_folio, tipo: 'string' },
      { nombre: 'p_placa', valor: f.placa, tipo: 'string' },
      { nombre: 'p_infraccion', valor: f.infraccion, tipo: 'integer' },
      { nombre: 'p_estado', valor: f.estado, tipo: 'integer' },
      { nombre: 'p_vigilante', valor: f.vigilante, tipo: 'integer' },
      { nombre: 'p_usu_inicial', valor: f.usu_inicial, tipo: 'integer' },
      { nombre: 'p_zona', valor: f.zona, tipo: 'integer' },
      { nombre: 'p_espacio', valor: f.espacio, tipo: 'integer' }
    ]
    const resp = await apiService.execute('sp_insert_folio_adeudo', 'estacionamiento_publico', params)
    message.value = resp?.message || 'Guardado'
  } finally { loading.value = false }
}
</script>

