<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="search-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Consulta Individual de Pagos del Local</h1>
        <p>Inicio > Mercados > Consulta de Pagos</p>
      </div>
    </div>

    <div class="module-view-content">
    <div class="municipal-card mb-3">
      <div class="municipal-card-header">
        <h5>Consulta Individual de Pagos del Local</h5>
      </div>
      <div class="municipal-card-body">
        <form @submit.prevent="buscarPago">
          <div class="row">
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">ID Local *</label>
              <input v-model.number="form.id_local" type="number" class="municipal-form-control" required :disabled="loading" />
            </div>
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Año *</label>
              <input v-model.number="form.axo" type="number" class="municipal-form-control" required :disabled="loading" />
            </div>
            <div class="col-md-3 mb-3">
              <label class="municipal-form-label">Mes *</label>
              <input v-model.number="form.periodo" type="number" class="municipal-form-control" min="1" max="12" required :disabled="loading" />
            </div>
            <div class="col-md-3 mb-3 d-flex align-items-end">
              <button type="submit" class="btn-municipal-primary w-100" :disabled="loading">
                <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
                Buscar
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>

    <div v-if="loading" class="text-center py-4">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Cargando...</span>
      </div>
    </div>

    <div v-if="pago" class="municipal-card mb-3">
      <div class="municipal-card-header">
        <h5>Datos del Mercado</h5>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="table table-bordered">
            <tbody>
              <tr><th class="bg-light" style="width: 30%;">Oficina</th><td>{{ pago.oficina }}</td></tr>
              <tr><th class="bg-light">Mercado</th><td>{{ pago.num_mercado }}</td></tr>
              <tr><th class="bg-light">Categoría</th><td>{{ pago.categoria }}</td></tr>
              <tr><th class="bg-light">Sección</th><td>{{ pago.seccion }}</td></tr>
              <tr><th class="bg-light">Local</th><td>{{ pago.local }}</td></tr>
              <tr><th class="bg-light">Letra</th><td>{{ pago.letra_local }}</td></tr>
              <tr><th class="bg-light">Bloque</th><td>{{ pago.bloque }}</td></tr>
              <tr><th class="bg-light">Descripción</th><td>{{ pago.descripcion_local }}</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <div v-if="pago" class="municipal-card mb-3">
      <div class="municipal-card-header">
        <h5>Datos del Pago</h5>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="table table-bordered">
            <tbody>
              <tr><th class="bg-light" style="width: 30%;">Control</th><td>{{ pago.id_local }}</td></tr>
              <tr><th class="bg-light">Año</th><td>{{ pago.axo }}</td></tr>
              <tr><th class="bg-light">Mes</th><td>{{ pago.periodo }}</td></tr>
              <tr><th class="bg-light">Fecha de Pago</th><td>{{ formatDate(pago.fecha_pago) }}</td></tr>
              <tr><th class="bg-light">Oficina de Pago</th><td>{{ pago.oficina_pago }}</td></tr>
              <tr><th class="bg-light">Caja de Pago</th><td>{{ pago.caja_pago }}</td></tr>
              <tr><th class="bg-light">Operación de Pago</th><td>{{ pago.operacion_pago }}</td></tr>
              <tr><th class="bg-light">Importe Pagado</th><td>{{ formatCurrency(pago.importe_pago) }}</td></tr>
              <tr><th class="bg-light">Partida</th><td>{{ pago.folio }}</td></tr>
              <tr><th class="bg-light">Actualización</th><td>{{ formatDate(pago.fecha_modificacion_1) }}</td></tr>
              <tr><th class="bg-light">Usuario</th><td>{{ pago.usuario }}</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import axios from 'axios'
import { useToast } from 'vue-toastification'

const toast = useToast()
const loading = ref(false)
const pago = ref(null)

const form = ref({
  id_local: '',
  axo: '',
  periodo: ''
})

const buscarPago = async () => {
  loading.value = true
  pago.value = null

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'pagos_individual_get',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_local', Valor: parseInt(form.value.id_local) },
          { Nombre: 'p_axo', Valor: parseInt(form.value.axo) },
          { Nombre: 'p_periodo', Valor: parseInt(form.value.periodo) }
        ]
      }
    })

    if (response.data?.eResponse?.success && response.data.eResponse.data?.result && response.data.eResponse.data.result.length > 0) {
      pago.value = response.data.eResponse.data.result[0]
      toast.success('Pago encontrado')
    } else {
      toast.warning('No se encontró el pago')
    }
  } catch (error) {
    toast.error('Error al buscar el pago')
    console.error('Error:', error)
  } finally {
    loading.value = false
  }
}

const formatDate = (dateStr) => {
  if (!dateStr) return ''
  const date = new Date(dateStr)
  return date.toLocaleDateString('es-MX')
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}
</script>

<style scoped>
/* Estilos adicionales si son necesarios */
</style>
