<template>
  <div class="container mt-4">
    <h1 class="mb-3">Carga de Pagos del Tianguis Cultural</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Carga TCultural</li>
      </ol>
    </nav>
    <form @submit.prevent="buscarAdeudos">
      <div class="form-row">
        <div class="form-group col-md-2">
          <label>Folio Desde</label>
          <input v-model="form.local_desde" type="number" class="form-control" required />
        </div>
        <div class="form-group col-md-2">
          <label>Folio Hasta</label>
          <input v-model="form.local_hasta" type="number" class="form-control" required />
        </div>
        <div class="form-group col-md-2">
          <label>Periodo</label>
          <input v-model="form.periodo" type="number" min="1" max="4" class="form-control" required />
        </div>
        <div class="form-group col-md-2">
          <label>Año</label>
          <input v-model="form.axo" type="number" min="2007" max="2999" class="form-control" required />
        </div>
        <div class="form-group col-md-2 align-self-end">
          <button type="submit" class="btn btn-primary">Buscar</button>
        </div>
      </div>
    </form>
    <div v-if="adeudos.length">
      <h3 class="mt-4 mb-3">Adeudos Encontrados</h3>
      <div class="table-responsive">
        <table class="table table-bordered table-sm table-hover">
          <thead class="thead-light">
            <tr>
              <th>CONTROL</th>
              <th>LOCAL</th>
              <th>NOMBRE</th>
              <th>%DESC.</th>
              <th>AÑO</th>
              <th>TRIM.</th>
              <th>PAGO T.</th>
              <th>FECHA</th>
              <th>REC</th>
              <th>CAJA</th>
              <th>OPER.</th>
              <th>PARTIDA</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in pagos" :key="idx">
              <td>{{ row.id_local }}</td>
              <td>{{ row.local }}</td>
              <td>{{ row.nombre }}</td>
              <td>{{ row.descuento }}</td>
              <td>{{ row.axo }}</td>
              <td>{{ row.periodo }}</td>
              <td>{{ row.importe }}</td>
              <td><input v-model="row.fecha_pago" type="date" class="form-control form-control-sm" /></td>
              <td><input v-model="row.rec" type="number" class="form-control form-control-sm" /></td>
              <td><input v-model="row.caja" type="text" class="form-control form-control-sm" maxlength="2" /></td>
              <td><input v-model="row.operacion" type="number" class="form-control form-control-sm" /></td>
              <td><input v-model="row.partida" type="text" class="form-control form-control-sm" /></td>
            </tr>
          </tbody>
        </table>
      </div>
      <div class="mb-3">
        <button class="btn btn-success" @click="validarPagos">Validar Folios</button>
        <button class="btn btn-primary ml-2" @click="guardarPagos" :disabled="!puedeGuardar">Guardar Pagos</button>
      </div>
      <div v-if="foliosErroneos.length" class="alert alert-danger" role="alert">
        <strong>Folios erróneos:</strong> {{ foliosErroneos.join(', ') }}
      </div>
      <div v-if="mensaje" class="alert alert-info" role="alert">{{ mensaje }}</div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import axios from 'axios'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useToast } from '@/composables/useToast'

// Composables
const globalLoading = useGlobalLoading()
const { showToast } = useToast()

// Reactive state
const form = reactive({
  local_desde: '',
  local_hasta: '',
  periodo: 1,
  axo: new Date().getFullYear()
})

const adeudos = ref([])
const pagos = ref([])
const foliosErroneos = ref([])
const mensaje = ref('')
const puedeGuardar = ref(false)

// Methods
const buscarAdeudos = async () => {
  mensaje.value = ''
  foliosErroneos.value = []
  puedeGuardar.value = false
  adeudos.value = []
  pagos.value = []

  await globalLoading.withLoading(async () => {
    try {
      const { data } = await axios.post('/api/execute', {
        eRequest: 'getAdeudosTCultural',
        payload: form
      })

      if (data.eResponse.success) {
        adeudos.value = data.eResponse.data
        // Map to pagos editable
        pagos.value = adeudos.value.map(row => ({
          id_local: row.id_local,
          local: row.local,
          nombre: row.nombre,
          descuento: row.descuento,
          axo: row.axo,
          periodo: row.periodo,
          importe: row.importe,
          fecha_pago: '',
          rec: '',
          caja: '',
          operacion: '',
          partida: ''
        }))
        showToast(`Se encontraron ${adeudos.value.length} adeudos`, 'success')
      } else {
        const msg = data.eResponse.message || 'No se encontraron adeudos.'
        mensaje.value = msg
        showToast(msg, 'warning')
      }
    } catch (e) {
      const errorMsg = 'Error al buscar adeudos: ' + e
      mensaje.value = errorMsg
      showToast(errorMsg, 'error')
    }
  }, 'Buscando adeudos...', 'Por favor espere')
}

const validarPagos = async () => {
  mensaje.value = ''
  foliosErroneos.value = []
  puedeGuardar.value = false

  await globalLoading.withLoading(async () => {
    try {
      const { data } = await axios.post('/api/execute', {
        eRequest: 'validatePagosTCultural',
        payload: { pagos: pagos.value }
      })

      if (data.eResponse.success) {
        foliosErroneos.value = data.eResponse.data.foliosErroneos || []
        if (foliosErroneos.value.length === 0) {
          mensaje.value = 'Todos los folios son válidos. Puede guardar.'
          puedeGuardar.value = true
          showToast('Validación exitosa. Todos los folios son válidos', 'success')
        } else {
          mensaje.value = 'Existen folios erróneos.'
          showToast(`Se encontraron ${foliosErroneos.value.length} folios erróneos`, 'warning')
        }
      } else {
        mensaje.value = data.eResponse.message
        showToast(data.eResponse.message, 'error')
      }
    } catch (e) {
      const errorMsg = 'Error al validar folios: ' + e
      mensaje.value = errorMsg
      showToast(errorMsg, 'error')
    }
  }, 'Validando folios...', 'Verificando datos')
}

const guardarPagos = async () => {
  mensaje.value = ''

  await globalLoading.withLoading(async () => {
    try {
      const { data } = await axios.post('/api/execute', {
        eRequest: 'savePagosTCultural',
        payload: { pagos: pagos.value }
      })

      if (data.eResponse.success) {
        mensaje.value = 'Pagos cargados correctamente.'
        showToast('Pagos guardados exitosamente', 'success')
        buscarAdeudos()
      } else {
        mensaje.value = data.eResponse.message
        showToast(data.eResponse.message, 'error')
      }
    } catch (e) {
      const errorMsg = 'Error al guardar pagos: ' + e
      mensaje.value = errorMsg
      showToast(errorMsg, 'error')
    }
  }, 'Guardando pagos...', 'Procesando información')
}
</script>
