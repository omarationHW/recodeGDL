<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="edit" /></div>
      <div class="module-view-info">
        <h1>Actualización — Estacionamientos Públicos</h1>
        <p>Modificar datos del registro</p>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-primary" @click="update" :disabled="updating">
          <font-awesome-icon icon="save" /> Guardar cambios
        </button>
      </div>
    </div>
    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group"><label class="municipal-form-label">Opción</label><input class="municipal-form-control" type="number" v-model.number="form.opc" placeholder="0" /></div>
          <div class="form-group"><label class="municipal-form-label">ID PubMain</label><input class="municipal-form-control" type="number" v-model.number="form.pubmain_id" /></div>
          <div class="form-group"><label class="municipal-form-label">Año</label><input class="municipal-form-control" type="number" v-model.number="form.axo" /></div>
        </div>
        <div class="form-row">
          <div class="form-group"><label class="municipal-form-label">Mes</label><input class="municipal-form-control" type="number" v-model.number="form.mes" min="1" max="12" /></div>
          <div class="form-group"><label class="municipal-form-label">Tipo</label><input class="municipal-form-control" type="number" v-model.number="form.tipo" /></div>
          <div class="form-group"><label class="municipal-form-label">Fecha</label><input type="date" class="municipal-form-control" v-model="form.fecha" /></div>
        </div>
        <div class="form-row">
          <div class="form-group"><label class="municipal-form-label">Recaudadora</label><input class="municipal-form-control" type="number" v-model.number="form.reca" /></div>
          <div class="form-group"><label class="municipal-form-label">Caja</label><input class="municipal-form-control" v-model="form.caja" /></div>
          <div class="form-group"><label class="municipal-form-label">Operación</label><input class="municipal-form-control" type="number" v-model.number="form.operacion" /></div>
        </div>
          <div v-if="message" class="text-muted">{{ message }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive, ref } from 'vue'
import apiService from '@/services/apiService'

const updating = ref(false)
const message = ref('')

// Delphi: actualiza_pub_pago(opc, pubmain_id, axo, mes, tipo, fecha, reca, caja, operacion)
const form = reactive({ opc: 0, pubmain_id: 0, axo: 0, mes: 0, tipo: 0, fecha: '', reca: 0, caja: '', operacion: 0 })

async function update() {
  updating.value = true
  message.value = ''
  try {
    const parametros = [
      { nombre: 'opc', valor: form.opc, tipo: 'integer' },
      { nombre: 'pubmain_id', valor: form.pubmain_id, tipo: 'integer' },
      { nombre: 'axo', valor: form.axo, tipo: 'integer' },
      { nombre: 'mes', valor: form.mes, tipo: 'integer' },
      { nombre: 'tipo', valor: form.tipo, tipo: 'integer' },
      { nombre: 'fecha', valor: form.fecha, tipo: 'string' },
      { nombre: 'reca', valor: form.reca, tipo: 'integer' },
      { nombre: 'caja', valor: form.caja, tipo: 'string' },
      { nombre: 'operacion', valor: form.operacion, tipo: 'integer' }
    ]
    const resp = await apiService.execute('actualiza_pub_pago', 'estacionamiento_publico', parametros)
    message.value = resp?.message || (resp?.success ? 'Actualizado correctamente' : 'No se pudo actualizar')
  } catch (e) {
    message.value = e.message || 'Error en la actualización'
  } finally {
    updating.value = false
  }
}
</script>
