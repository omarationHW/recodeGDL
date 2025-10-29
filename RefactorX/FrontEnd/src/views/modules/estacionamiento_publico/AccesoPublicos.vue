<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="right-to-bracket" /></div>
      <div class="module-view-info">
        <h1>Accesos — Estacionamientos Públicos</h1>
        <p>Registro de entradas y salidas</p>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Opción</label><input class="municipal-form-control" type="number" v-model.number="form.opc" placeholder="0" /></div>
            <div class="form-group"><label class="municipal-form-label">ID PubMain</label><input class="municipal-form-control" type="number" v-model.number="form.pubmain_id" /></div>
            <div class="form-group"><label class="municipal-form-label">Fecha</label><input class="municipal-form-control" type="date" v-model="form.fecha" /></div>
          </div>
          <div class="form-row">
            <div class="form-group"><label class="municipal-form-label">Cajones</label><input class="municipal-form-control" type="number" v-model.number="form.cajones" /></div>
            <div class="form-group"><label class="municipal-form-label">Categoría</label><input class="municipal-form-control" type="number" v-model.number="form.categoria" /></div>
            <div class="form-group"><label class="municipal-form-label">Oficio</label><input class="municipal-form-control" v-model="form.oficio" /></div>
            <div class="form-group"><label class="municipal-form-label">Usuario</label><input class="municipal-form-control" type="number" v-model.number="form.usuario" /></div>
          </div>
          <div class="button-group">
            <button class="btn-municipal-primary" :disabled="loading" @click="registrar"><font-awesome-icon icon="check" /> Registrar</button>
          </div>
          <div v-if="loading" class="spinner-border" role="status"><span class="visually-hidden">Procesando...</span></div>
          <p v-if="message" class="text-muted">{{ message }}</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import apiService from '@/services/apiService'

// Delphi: sp_pub_movtos(opc, pubmain_id, fecha, cajones, categoria, oficio, usuario)
const form = reactive({ opc: 0, pubmain_id: 0, fecha: '', cajones: 0, categoria: 0, oficio: '', usuario: 0 })
const loading = ref(false)
const message = ref('')

async function registrar() {
  loading.value = true
  message.value = ''
  try {
    const parametros = [
      { nombre: 'opc', valor: form.opc, tipo: 'integer' },
      { nombre: 'pubmain_id', valor: form.pubmain_id, tipo: 'integer' },
      { nombre: 'fecha', valor: form.fecha, tipo: 'string' },
      { nombre: 'cajones', valor: form.cajones, tipo: 'integer' },
      { nombre: 'categoria', valor: form.categoria, tipo: 'integer' },
      { nombre: 'oficio', valor: form.oficio, tipo: 'string' },
      { nombre: 'usuario', valor: form.usuario, tipo: 'integer' }
    ]
    const resp = await apiService.execute('sp_pub_movtos', 'estacionamiento_publico', parametros)
    message.value = resp?.message || (resp?.success ? 'Acceso registrado' : 'No se pudo registrar')
  } catch (e) {
    message.value = e.message || 'Error en la operación'
  } finally {
    loading.value = false
  }
}
</script>
