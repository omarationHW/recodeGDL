<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="map-marked-alt" />
      </div>
      <div class="module-view-info">
        <h1>Traslados por Ubicación</h1>
        <p>Cementerios - Traslado de pagos entre ubicaciones físicas</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-purple"
          @click="mostrarAyuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <!-- Ubicaciones -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <font-awesome-icon icon="map-pin" />
        Ubicaciones Físicas
      </div>
      <div class="municipal-card-body">
        <div class="ubicaciones-grid">
          <!-- Ubicación Origen -->
          <div class="ubicacion-form">
            <h3 class="ubicacion-title origin">
              <font-awesome-icon icon="arrow-right" />
              Ubicación Origen
            </h3>

            <div class="form-group">
              <label class="form-label required">Cementerio</label>
              <select v-model="origen.cementerio" class="municipal-form-control">
                <option value="">-- Seleccione --</option>
                <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                  {{ cem.cementerio }} - {{ cem.nombre }}
                </option>
              </select>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Clase</label>
                <input type="number" v-model.number="origen.clase" class="municipal-form-control" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Clase Alfa</label>
                <input v-model="origen.clase_alfa" class="municipal-form-control" maxlength="2" />
              </div>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Sección</label>
                <input type="number" v-model.number="origen.seccion" class="municipal-form-control" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Sección Alfa</label>
                <input v-model="origen.seccion_alfa" class="municipal-form-control" maxlength="2" />
              </div>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Línea</label>
                <input type="number" v-model.number="origen.linea" class="municipal-form-control" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Línea Alfa</label>
                <input v-model="origen.linea_alfa" class="municipal-form-control" maxlength="2" />
              </div>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Fosa</label>
                <input type="number" v-model.number="origen.fosa" class="municipal-form-control" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fosa Alfa</label>
                <input v-model="origen.fosa_alfa" class="municipal-form-control" maxlength="4" />
              </div>
            </div>
          </div>

          <div class="transfer-arrow">
            <font-awesome-icon icon="arrow-circle-right" />
          </div>

          <!-- Ubicación Destino -->
          <div class="ubicacion-form">
            <h3 class="ubicacion-title destination">
              <font-awesome-icon icon="arrow-left" />
              Ubicación Destino
            </h3>

            <div class="form-group">
              <label class="form-label required">Cementerio</label>
              <select v-model="destino.cementerio" class="municipal-form-control">
                <option value="">-- Seleccione --</option>
                <option v-for="cem in cementerios" :key="cem.cementerio" :value="cem.cementerio">
                  {{ cem.cementerio }} - {{ cem.nombre }}
                </option>
              </select>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Clase</label>
                <input type="number" v-model.number="destino.clase" class="municipal-form-control" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Clase Alfa</label>
                <input v-model="destino.clase_alfa" class="municipal-form-control" maxlength="2" />
              </div>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Sección</label>
                <input type="number" v-model.number="destino.seccion" class="municipal-form-control" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Sección Alfa</label>
                <input v-model="destino.seccion_alfa" class="municipal-form-control" maxlength="2" />
              </div>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Línea</label>
                <input type="number" v-model.number="destino.linea" class="municipal-form-control" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Línea Alfa</label>
                <input v-model="destino.linea_alfa" class="municipal-form-control" maxlength="2" />
              </div>
            </div>

            <div class="form-grid-two">
              <div class="form-group">
                <label class="form-label required">Fosa</label>
                <input type="number" v-model.number="destino.fosa" class="municipal-form-control" />
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Fosa Alfa</label>
                <input v-model="destino.fosa_alfa" class="municipal-form-control" maxlength="4" />
              </div>
            </div>
          </div>
        </div>

        <div class="form-actions mt-3">
          <button class="btn-municipal-primary" @click="verificarUbicaciones" :disabled="!ubicacionesValidas">
            <font-awesome-icon icon="search" />
            Verificar Ubicaciones
          </button>
        </div>
      </div>
    </div>

    <!-- Pagos Encontrados -->
    <div v-if="pagosOrigen.length > 0" class="municipal-card mt-3">
      <div class="municipal-card-header">
        <font-awesome-icon icon="list" />
        Pagos en Ubicación Origen ({{ pagosOrigen.length }})
      </div>
      <div class="municipal-card-body">
        <div v-if="folioDestino" class="alert-info mb-3">
          <font-awesome-icon icon="info-circle" />
          <span>
            Destino: Folio {{ folioDestino.control_rcm }} - {{ folioDestino.nombre }}
          </span>
        </div>

        <div class="table-container">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Control ID</th>
                <th>Folio</th>
                <th>Fecha</th>
                <th>Años</th>
                <th>Importe</th>
                <th>Recargos</th>
                <th>Total</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="pago in pagosOrigen" :key="pago.control_id">
                <td>{{ pago.control_id }}</td>
                <td>{{ pago.control_rcm }}</td>
                <td>{{ formatDate(pago.fecing) }}</td>
                <td>{{ pago.axo_pago_desde }}-{{ pago.axo_pago_hasta }}</td>
                <td>{{ formatCurrency(pago.importe_anual) }}</td>
                <td>{{ formatCurrency(pago.importe_recargos) }}</td>
                <td class="text-bold">
                  {{ formatCurrency(pago.importe_anual + pago.importe_recargos) }}
                </td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="form-actions mt-3">
          <button class="btn-municipal-secondary" @click="cancelar">
            <font-awesome-icon icon="times" />
            Cancelar
          </button>
          <button class="btn-municipal-primary" @click="confirmarTraslado">
            <font-awesome-icon icon="exchange-alt" />
            Trasladar {{ pagosOrigen.length }} Pago(s)
          </button>
        </div>
      </div>
    </div>

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'Traslados'"
      :moduleName="'cementerios'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const { callProcedure } = useApi()

// Sistema de toast manual
const toast = ref({
  show: false,
  type: 'info',
  message: ''
})

let toastTimeout = null

const showToast = (type, message) => {
  if (toastTimeout) {
    clearTimeout(toastTimeout)
  }

  toast.value = {
    show: true,
    type,
    message
  }

  toastTimeout = setTimeout(() => {
    hideToast()
  }, 3000)
}

const hideToast = () => {
  toast.value.show = false
}

const getToastIcon = (type) => {
  const icons = {
    success: 'check-circle',
    error: 'exclamation-circle',
    warning: 'exclamation-triangle',
    info: 'info-circle'
  }
  return icons[type] || 'info-circle'
}

// Estado
const showDocumentation = ref(false)
const mostrarAyuda = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const cementerios = ref([])
const pagosOrigen = ref([])
const folioDestino = ref(null)

const origen = ref({
  cementerio: '',
  clase: null,
  clase_alfa: '',
  seccion: null,
  seccion_alfa: '',
  linea: null,
  linea_alfa: '',
  fosa: null,
  fosa_alfa: ''
})

const destino = ref({
  cementerio: '',
  clase: null,
  clase_alfa: '',
  seccion: null,
  seccion_alfa: '',
  linea: null,
  linea_alfa: '',
  fosa: null,
  fosa_alfa: ''
})

const ubicacionesValidas = computed(() => {
  return origen.value.cementerio && origen.value.clase && origen.value.seccion &&
         origen.value.linea && origen.value.fosa &&
         destino.value.cementerio && destino.value.clase && destino.value.seccion &&
         destino.value.linea && destino.value.fosa
})

onMounted(async () => {
  try {
    const result = await callProcedure('sp_cem_listar_cementerios', [], 'cementerio', 'public')
    cementerios.value = result.data || []
  } catch (error) {
    console.error('Error al cargar cementerios:', error)
  }
})

const verificarUbicaciones = async () => {
  try {
    // Buscar pagos en ubicación origen
    const resultPagos = await callProcedure('sp_traslados_buscar_pagos_origen', [
      { nombre: 'p_cementerio', valor: origen.value.cementerio, tipo: 'varchar' },
      { nombre: 'p_clase', valor: origen.value.clase, tipo: 'integer' },
      { nombre: 'p_clase_alfa', valor: origen.value.clase_alfa || null, tipo: 'varchar' },
      { nombre: 'p_seccion', valor: origen.value.seccion, tipo: 'integer' },
      { nombre: 'p_seccion_alfa', valor: origen.value.seccion_alfa || null, tipo: 'varchar' },
      { nombre: 'p_linea', valor: origen.value.linea, tipo: 'integer' },
      { nombre: 'p_linea_alfa', valor: origen.value.linea_alfa || null, tipo: 'varchar' },
      { nombre: 'p_fosa', valor: origen.value.fosa, tipo: 'integer' },
      { nombre: 'p_fosa_alfa', valor: origen.value.fosa_alfa || null, tipo: 'varchar' }
    ], 'padron_licencias', 'public')

    pagosOrigen.value = resultPagos.data || []

    if (pagosOrigen.value.length === 0) {
      showToast('error', 'No se encontraron pagos en la ubicación origen')
      return
    }

    // Buscar folio destino
    const resultFolio = await callProcedure('sp_traslados_buscar_folio_destino', [
      { nombre: 'p_cementerio', valor: destino.value.cementerio, tipo: 'varchar' },
      { nombre: 'p_clase', valor: destino.value.clase, tipo: 'integer' },
      { nombre: 'p_clase_alfa', valor: destino.value.clase_alfa || null, tipo: 'varchar' },
      { nombre: 'p_seccion', valor: destino.value.seccion, tipo: 'integer' },
      { nombre: 'p_seccion_alfa', valor: destino.value.seccion_alfa || null, tipo: 'varchar' },
      { nombre: 'p_linea', valor: destino.value.linea, tipo: 'integer' },
      { nombre: 'p_linea_alfa', valor: destino.value.linea_alfa || null, tipo: 'varchar' },
      { nombre: 'p_fosa', valor: destino.value.fosa, tipo: 'integer' },
      { nombre: 'p_fosa_alfa', valor: destino.value.fosa_alfa || null, tipo: 'varchar' }
    ], 'padron_licencias', 'public')

    const folioData = resultFolio.data && resultFolio.data.length > 0 ? resultFolio.data[0] : null

    if (!folioData || folioData.resultado !== 'S') {
      showToast('error', 'No se encontró folio en la ubicación destino')
      return
    }

    folioDestino.value = {
      control_rcm: folioData.control_rcm,
      nombre: folioData.nombre
    }

  } catch (error) {
    console.error('Error al verificar ubicaciones:', error)
    showToast('error', 'Error al verificar las ubicaciones')
  }
}

const confirmarTraslado = async () => {
  const result = await Swal.fire({
    title: '¿Confirmar traslado?',
    html: `Se trasladarán <strong>${pagosOrigen.value.length}</strong> pago(s)<br>al folio <strong>${folioDestino.value.control_rcm}</strong>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, trasladar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d'
  })

  if (!result.isConfirmed) return

  try {
    const resultTraslado = await callProcedure('sp_traslados_trasladar_pagos_ubicacion', [
      { nombre: 'p_cem_origen', valor: origen.value.cementerio, tipo: 'varchar' },
      { nombre: 'p_clase_origen', valor: origen.value.clase, tipo: 'integer' },
      { nombre: 'p_clase_alfa_origen', valor: origen.value.clase_alfa || null, tipo: 'varchar' },
      { nombre: 'p_sec_origen', valor: origen.value.seccion, tipo: 'integer' },
      { nombre: 'p_sec_alfa_origen', valor: origen.value.seccion_alfa || null, tipo: 'varchar' },
      { nombre: 'p_lin_origen', valor: origen.value.linea, tipo: 'integer' },
      { nombre: 'p_lin_alfa_origen', valor: origen.value.linea_alfa || null, tipo: 'varchar' },
      { nombre: 'p_fosa_origen', valor: origen.value.fosa, tipo: 'integer' },
      { nombre: 'p_fosa_alfa_origen', valor: origen.value.fosa_alfa || null, tipo: 'varchar' },
      { nombre: 'p_cem_destino', valor: destino.value.cementerio, tipo: 'varchar' },
      { nombre: 'p_clase_destino', valor: destino.value.clase, tipo: 'integer' },
      { nombre: 'p_clase_alfa_destino', valor: destino.value.clase_alfa || null, tipo: 'varchar' },
      { nombre: 'p_sec_destino', valor: destino.value.seccion, tipo: 'integer' },
      { nombre: 'p_sec_alfa_destino', valor: destino.value.seccion_alfa || null, tipo: 'varchar' },
      { nombre: 'p_lin_destino', valor: destino.value.linea, tipo: 'integer' },
      { nombre: 'p_lin_alfa_destino', valor: destino.value.linea_alfa || null, tipo: 'varchar' },
      { nombre: 'p_fosa_destino', valor: destino.value.fosa, tipo: 'integer' },
      { nombre: 'p_fosa_alfa_destino', valor: destino.value.fosa_alfa || null, tipo: 'varchar' },
      { nombre: 'p_control_rcm_destino', valor: folioDestino.value.control_rcm, tipo: 'integer' },
      { nombre: 'p_usuario', valor: 1, tipo: 'integer' }
    ], 'padron_licencias', 'public')

    const trasladoData = resultTraslado.data && resultTraslado.data.length > 0 ? resultTraslado.data[0] : null

    if (trasladoData && trasladoData.resultado === 'S') {
      showToast('success', `${trasladoData.registros_actualizados} pago(s) trasladados exitosamente`)
      cancelar()
    } else {
      showToast('error', trasladoData?.mensaje || 'Error al trasladar')
    }
  } catch (error) {
    console.error('Error al trasladar:', error)
    showToast('error', 'Error al realizar el traslado')
  }
}

const cancelar = () => {
  origen.value = { cementerio: '', clase: null, clase_alfa: '', seccion: null, seccion_alfa: '', linea: null, linea_alfa: '', fosa: null, fosa_alfa: '' }
  destino.value = { cementerio: '', clase: null, clase_alfa: '', seccion: null, seccion_alfa: '', linea: null, linea_alfa: '', fosa: null, fosa_alfa: '' }
  pagosOrigen.value = []
  folioDestino.value = null
}

const formatCurrency = (value) => {
  if (value == null) return '$0.00'
  return new Intl.NumberFormat('es-MX', { style: 'currency', currency: 'MXN' }).format(value)
}

const formatDate = (date) => {
  if (!date) return ''
  return new Date(date).toLocaleDateString('es-MX')
}
</script>
