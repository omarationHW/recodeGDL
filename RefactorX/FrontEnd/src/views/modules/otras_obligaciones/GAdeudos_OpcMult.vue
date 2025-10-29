<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="list-check" />
      </div>
      <div class="module-view-info">
        <h1>{{ tituloModulo }}</h1>
        <p>Otras Obligaciones - Opciones Múltiples de Adeudos</p>
      </div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button
          class="btn-municipal-secondary"
          @click="goBack"
          :disabled="loading"
        >
          <font-awesome-icon icon="arrow-left" />
          Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Selector de Tabla y Opción -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="table" />
            Configuración Inicial
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group" style="flex: 1;">
              <label class="municipal-form-label">
                <strong>Tabla:</strong>
                <span class="required">*</span>
              </label>
              <select
                v-model="selectedTabla"
                @change="onTablaChange"
                class="municipal-form-control"
                :disabled="loading"
              >
                <option value="">-- Seleccione una tabla --</option>
                <option
                  v-for="tabla in tablas"
                  :key="tabla.cve_tab"
                  :value="tabla.cve_tab"
                >
                  {{ tabla.cve_tab }} - {{ tabla.nombre }}
                </option>
              </select>
            </div>

            <div class="form-group" style="flex: 1;">
              <label class="municipal-form-label">
                <strong>Opción:</strong>
                <span class="required">*</span>
              </label>
              <select
                v-model="selectedOpcion"
                @change="onOpcionChange"
                class="municipal-form-control"
                :disabled="loading"
              >
                <option value="">-- Seleccione una opción --</option>
                <option value="1">P - DAR DE PAGADO</option>
                <option value="2">S - CONDONAR</option>
                <option value="3">C - CANCELAR</option>
                <option value="4">R - PRESCRIBIR</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Búsqueda de Concesión -->
      <div class="municipal-card" v-if="selectedTabla && selectedOpcion">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            {{ etiquetas.etiq_control || 'Búsqueda' }}
          </h5>
        </div>

        <div class="municipal-card-body">
          <!-- Búsqueda por Número de Expediente (Tablas 1, 2, 4, 5) -->
          <div v-if="selectedTabla !== '3'" class="form-row">
            <div class="form-group" style="flex: 0 0 250px;">
              <label class="municipal-form-label">
                <strong>{{ etiquetas.etiq_control }}:</strong>
                <span class="required">*</span>
              </label>
              <div class="input-group">
                <span class="input-group-text" v-if="etiquetas.abreviatura">
                  {{ etiquetas.abreviatura }}
                </span>
                <input
                  v-model="busqueda.numExpediente"
                  type="text"
                  class="municipal-form-control"
                  :placeholder="`Número de ${etiquetas.etiq_control}`"
                  maxlength="6"
                  @keyup.enter="buscarConcesion"
                />
              </div>
            </div>
            <div class="form-group" style="flex: 0;">
              <label class="municipal-form-label" style="visibility: hidden;">Buscar</label>
              <button
                type="button"
                class="btn-municipal-primary"
                @click="buscarConcesion"
                :disabled="!busqueda.numExpediente || loading"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>

          <!-- Búsqueda por Número de Local (Tabla 3) -->
          <div v-else class="form-row">
            <div class="form-group" style="flex: 0 0 150px;">
              <label class="municipal-form-label">
                <strong>Número de Local:</strong>
                <span class="required">*</span>
              </label>
              <input
                v-model="busqueda.numLocal"
                type="text"
                class="municipal-form-control"
                placeholder="Número"
                maxlength="3"
                @keyup.enter="focusLetra"
              />
            </div>
            <div class="form-group" style="flex: 0 0 100px;">
              <label class="municipal-form-label">
                <strong>Letra:</strong>
              </label>
              <input
                ref="letraInput"
                v-model="busqueda.letra"
                type="text"
                class="municipal-form-control"
                placeholder="Letra"
                maxlength="1"
                @keyup.enter="buscarConcesion"
              />
            </div>
            <div class="form-group" style="flex: 0;">
              <label class="municipal-form-label" style="visibility: hidden;">Buscar</label>
              <button
                type="button"
                class="btn-municipal-primary"
                @click="buscarConcesion"
                :disabled="!busqueda.numLocal || loading"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos de la Concesión -->
      <div class="municipal-card" v-if="datosGenerales">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Datos de la Concesión
          </h5>
          <span class="badge-info">{{ datosGenerales.statusregistro === 'A' ? 'ACTIVO' : 'INACTIVO' }}</span>
        </div>

        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item" v-if="datosGenerales.concesionario">
              <label>{{ etiquetas.concesionario }}:</label>
              <span>{{ datosGenerales.concesionario }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.ubicacion">
              <label>{{ etiquetas.ubicacion }}:</label>
              <span>{{ datosGenerales.ubicacion }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.nomcomercial">
              <label>{{ etiquetas.nombre_comercial }}:</label>
              <span>{{ datosGenerales.nomcomercial }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.lugar">
              <label>{{ etiquetas.lugar }}:</label>
              <span>{{ datosGenerales.lugar }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.unidades">
              <label>{{ etiquetas.unidad }}:</label>
              <span>{{ datosGenerales.unidades }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.superficie">
              <label>{{ etiquetas.superficie }}:</label>
              <span>{{ datosGenerales.superficie }} m²</span>
            </div>
            <div class="info-item" v-if="datosGenerales.fechainicio">
              <label>{{ etiquetas.fecha_inicio }}:</label>
              <span>{{ formatDate(datosGenerales.fechainicio) }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.fechafin">
              <label>{{ etiquetas.fecha_fin }}:</label>
              <span>{{ formatDate(datosGenerales.fechafin) }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.sector">
              <label>{{ etiquetas.sector }}:</label>
              <span>{{ datosGenerales.sector }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.licencia">
              <label>{{ etiquetas.licencia }}:</label>
              <span>{{ datosGenerales.licencia }}</span>
            </div>
            <div class="info-item" v-if="datosGenerales.obs">
              <label>{{ etiquetas.obs }}:</label>
              <span>{{ datosGenerales.obs }}</span>
            </div>
          </div>

          <!-- Botón Ver Pagados -->
          <div class="button-group mt-3" v-if="tienePagados">
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="verPagados"
            >
              <font-awesome-icon icon="history" />
              Ver Historial de Pagados
            </button>
          </div>
        </div>
      </div>

      <!-- Parámetros de Ejecución (solo para opción Pagado) -->
      <div class="municipal-card" v-if="datosGenerales && selectedOpcion === '1'">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="cog" />
            Parámetros de Pago
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group" style="flex: 1;">
              <label class="municipal-form-label">
                <strong>Fecha de Pago:</strong>
                <span class="required">*</span>
              </label>
              <input
                v-model="parametros.fechaPago"
                type="date"
                class="municipal-form-control"
              />
            </div>
            <div class="form-group" style="flex: 1;">
              <label class="municipal-form-label">
                <strong>Recaudadora:</strong>
                <span class="required">*</span>
              </label>
              <select
                v-model="parametros.recaudadora"
                class="municipal-form-control"
              >
                <option value="">-- Seleccione --</option>
                <option
                  v-for="rec in recaudadoras"
                  :key="rec.id_rec"
                  :value="rec.id_rec"
                >
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group" style="flex: 1;">
              <label class="municipal-form-label">
                <strong>Caja:</strong>
                <span class="required">*</span>
              </label>
              <input
                v-model="parametros.caja"
                type="text"
                class="municipal-form-control"
                maxlength="10"
                placeholder="Caja"
              />
            </div>
            <div class="form-group" style="flex: 1;">
              <label class="municipal-form-label">
                <strong>Consecutivo Operación:</strong>
                <span class="required">*</span>
              </label>
              <input
                v-model.number="parametros.consecutivo"
                type="number"
                class="municipal-form-control"
                min="1"
                placeholder="Consecutivo"
              />
            </div>
            <div class="form-group" style="flex: 1;">
              <label class="municipal-form-label">
                <strong>Folio Recibo:</strong>
                <span class="required">*</span>
              </label>
              <input
                v-model="parametros.folioRecibo"
                type="text"
                class="municipal-form-control"
                maxlength="20"
                placeholder="Folio"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Grid de Adeudos -->
      <div class="municipal-card" v-if="adeudos.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list-alt" />
            Adeudos Disponibles
            <span class="badge-info">{{ adeudosSeleccionados.length }} / {{ adeudos.length }} seleccionados</span>
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="alert alert-info mb-3">
            <font-awesome-icon icon="info-circle" />
            <strong>Instrucciones:</strong> Seleccione los adeudos que desea procesar marcando las casillas de verificación.
          </div>

          <!-- Tabla de adeudos -->
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th style="width: 5%;">
                    <input
                      type="checkbox"
                      :checked="todosSeleccionados"
                      @change="toggleTodos"
                      title="Seleccionar todos"
                    />
                  </th>
                  <th style="width: 20%;">Concepto</th>
                  <th style="width: 10%;">Año</th>
                  <th style="width: 10%;">Mes</th>
                  <th style="width: 15%; text-align: right;">Importe</th>
                  <th style="width: 15%; text-align: right;">Recargos</th>
                  <th style="width: 15%; text-align: right;">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(adeudo, idx) in adeudos" :key="idx">
                  <td class="text-center">
                    <input
                      type="checkbox"
                      v-model="adeudo.seleccionado"
                    />
                  </td>
                  <td>{{ adeudo.concepto }}</td>
                  <td>{{ adeudo.axo }}</td>
                  <td>{{ getMesNombre(adeudo.mes) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_pagar) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.recargos_pagar) }}</td>
                  <td class="text-right">
                    <strong>{{ formatCurrency(adeudo.importe_pagar + adeudo.recargos_pagar) }}</strong>
                  </td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="municipal-table-footer">
                  <td colspan="4" class="text-right"><strong>TOTALES:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalImporte) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalRecargos) }}</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalGeneral) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Botones de acción -->
          <div class="button-group mt-4">
            <button
              type="button"
              class="btn-municipal-primary"
              @click="ejecutarAccion"
              :disabled="!canEjecutar || saving"
            >
              <font-awesome-icon :icon="saving ? 'spinner' : 'check'" :spin="saving" />
              {{ saving ? 'Procesando...' : textoBotonEjecutar }}
            </button>
            <button
              type="button"
              class="btn-municipal-secondary"
              @click="limpiarBusqueda"
              :disabled="saving"
            >
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay adeudos -->
      <div class="municipal-card" v-else-if="datosGenerales && buscado">
        <div class="municipal-card-body">
          <div class="text-center text-muted">
            <font-awesome-icon icon="info-circle" size="2x" class="empty-icon" />
            <p>No se encontraron adeudos para esta concesión.</p>
          </div>
        </div>
      </div>

      <!-- Loading overlay -->
      <div v-if="loading" class="loading-overlay">
        <div class="loading-spinner">
          <div class="spinner"></div>
          <p>Cargando datos...</p>
        </div>
      </div>
    </div>
    <!-- /module-view-content -->

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>
  <!-- /module-view -->

  <!-- Modal de Ayuda -->
  <DocumentationModal
    :show="showDocumentation"
    :componentName="'GAdeudos_OpcMult'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />

  <!-- Modal de Pagados -->
  <div v-if="showPagadosModal" class="modal-overlay" @click.self="closePagadosModal">
    <div class="modal-container" style="max-width: 900px;">
      <div class="modal-header">
        <h3>
          <font-awesome-icon icon="history" />
          Historial de Pagados
        </h3>
        <button class="modal-close" @click="closePagadosModal">
          <font-awesome-icon icon="times" />
        </button>
      </div>
      <div class="modal-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Periodo</th>
                <th>Importe</th>
                <th>Recargo</th>
                <th>Fecha Pago</th>
                <th>Recaudadora</th>
                <th>Caja</th>
                <th>Operación</th>
                <th>Folio</th>
                <th>Usuario</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="pago in pagados" :key="pago.id_34_pagos">
                <td>{{ formatDate(pago.periodo) }}</td>
                <td class="text-right">{{ formatCurrency(pago.importe) }}</td>
                <td class="text-right">{{ formatCurrency(pago.recargo) }}</td>
                <td>{{ formatDateTime(pago.fecha_hora_pago) }}</td>
                <td>{{ pago.id_recaudadora }}</td>
                <td>{{ pago.caja }}</td>
                <td>{{ pago.operacion }}</td>
                <td>{{ pago.folio_recibo }}</td>
                <td>{{ pago.usuario }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn-municipal-secondary" @click="closePagadosModal">
          Cerrar
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Router
const router = useRouter()

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const tablas = ref([])
const recaudadoras = ref([])
const selectedTabla = ref('')
const selectedOpcion = ref('')
const etiquetas = ref({})
const busqueda = ref({
  numExpediente: '',
  numLocal: '',
  letra: ''
})
const datosGenerales = ref(null)
const adeudos = ref([])
const pagados = ref([])
const saving = ref(false)
const buscado = ref(false)
const tienePagados = ref(false)
const showPagadosModal = ref(false)

// Referencias
const letraInput = ref(null)

// Parámetros para operación Pagado
const parametros = ref({
  fechaPago: new Date().toISOString().split('T')[0],
  recaudadora: '',
  caja: '',
  consecutivo: null,
  folioRecibo: ''
})

// Computed
const tituloModulo = computed(() => {
  if (!selectedOpcion.value) return 'Opciones Múltiples de Adeudos'

  const opciones = {
    '1': 'DAR DE PAGADO ADEUDOS',
    '2': 'CONDONAR ADEUDOS',
    '3': 'CANCELAR ADEUDOS',
    '4': 'PRESCRIBIR ADEUDOS'
  }

  return opciones[selectedOpcion.value] || 'Opciones Múltiples de Adeudos'
})

const textoBotonEjecutar = computed(() => {
  const textos = {
    '1': 'Ejecutar Pagado',
    '2': 'Ejecutar Condonación',
    '3': 'Ejecutar Cancelación',
    '4': 'Ejecutar Prescripción'
  }
  return textos[selectedOpcion.value] || 'Ejecutar'
})

const adeudosSeleccionados = computed(() => {
  return adeudos.value.filter(a => a.seleccionado)
})

const todosSeleccionados = computed(() => {
  return adeudos.value.length > 0 && adeudos.value.every(a => a.seleccionado)
})

const totalImporte = computed(() => {
  return adeudosSeleccionados.value.reduce((sum, a) => sum + a.importe_pagar, 0)
})

const totalRecargos = computed(() => {
  return adeudosSeleccionados.value.reduce((sum, a) => sum + a.recargos_pagar, 0)
})

const totalGeneral = computed(() => {
  return totalImporte.value + totalRecargos.value
})

const canEjecutar = computed(() => {
  if (adeudosSeleccionados.value.length === 0 || saving.value) {
    return false
  }

  // Si es opción Pagado, validar parámetros adicionales
  if (selectedOpcion.value === '1') {
    return parametros.value.fechaPago &&
           parametros.value.recaudadora &&
           parametros.value.caja &&
           parametros.value.consecutivo &&
           parametros.value.folioRecibo
  }

  return true
})

// Métodos
const goBack = () => {
  router.push('/otras_obligaciones')
}

const focusLetra = () => {
  if (letraInput.value) {
    letraInput.value.focus()
  }
}

const formatCurrency = (value) => {
  if (value === null || value === undefined) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

const formatDate = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

const formatDateTime = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleString('es-MX', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const getMesNombre = (mes) => {
  const meses = [
    'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ]
  return meses[mes - 1] || mes
}

const toggleTodos = () => {
  const nuevoEstado = !todosSeleccionados.value
  adeudos.value.forEach(a => a.seleccionado = nuevoEstado)
}

// Cargar tablas disponibles
const loadTablas = async () => {
  try {
    const response = await execute(
      'SP_GADEUDOS_OPC_MULT_TABLAS_GET',
      'otras_obligaciones',
      [],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      tablas.value = response.result
      showToast('success', `${tablas.value.length} tabla(s) disponible(s)`)
    } else {
      tablas.value = []
      showToast('info', 'No se encontraron tablas disponibles')
    }
  } catch (error) {
    handleApiError(error)
    tablas.value = []
  }
}

// Cargar recaudadoras
const loadRecaudadoras = async () => {
  try {
    const response = await execute(
      'SP_GADEUDOS_OPC_MULT_RECAUDADORAS_GET',
      'otras_obligaciones',
      [],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      recaudadoras.value = response.result
      if (recaudadoras.value.length > 0) {
        parametros.value.recaudadora = recaudadoras.value[0].id_rec
      }
    } else {
      recaudadoras.value = []
    }
  } catch (error) {
    handleApiError(error)
    recaudadoras.value = []
  }
}

// Evento al cambiar la tabla
const onTablaChange = async () => {
  if (!selectedTabla.value) {
    etiquetas.value = {}
    limpiarBusqueda()
    return
  }

  setLoading(true, 'Cargando etiquetas...')

  try {
    const response = await execute(
      'SP_GADEUDOS_OPC_MULT_ETIQUETAS_GET',
      'otras_obligaciones',
      [
        { nombre: 'par_tab', valor: selectedTabla.value, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      etiquetas.value = response.result[0]
      showToast('success', 'Etiquetas cargadas')
    } else {
      etiquetas.value = {}
      showToast('warning', 'No se encontraron etiquetas para esta tabla')
    }
  } catch (error) {
    handleApiError(error)
    etiquetas.value = {}
  } finally {
    setLoading(false)
  }

  limpiarBusqueda()
}

// Evento al cambiar la opción
const onOpcionChange = () => {
  limpiarBusqueda()
}

// Buscar concesión
const buscarConcesion = async () => {
  if (!selectedTabla.value || !selectedOpcion.value) {
    showToast('warning', 'Debe seleccionar tabla y opción')
    return
  }

  let control = ''

  // Construir el control según la tabla
  if (selectedTabla.value === '3') {
    // Mercados: número-letra o solo número
    if (!busqueda.value.numLocal || busqueda.value.numLocal === '0') {
      showToast('warning', 'Falta el dato del NUMERO DE LOCAL, intentalo de nuevo')
      return
    }
    control = busqueda.value.letra
      ? `${busqueda.value.numLocal}-${busqueda.value.letra}`
      : busqueda.value.numLocal
  } else {
    // Otras tablas: abreviatura + número
    if (!busqueda.value.numExpediente || busqueda.value.numExpediente === '0') {
      showToast('warning', 'Falta el dato del NUMERO DE EXPEDIENTE, intentalo de nuevo')
      return
    }
    control = `${etiquetas.value.abreviatura || ''}${busqueda.value.numExpediente}`
  }

  setLoading(true, 'Buscando concesión...')

  try {
    // Buscar datos generales
    const response = await execute(
      'SP_GADEUDOS_OPC_MULT_DATOS_GENERALES_GET',
      'otras_obligaciones',
      [
        { nombre: 'par_tab', valor: selectedTabla.value, tipo: 'string' },
        { nombre: 'par_control', valor: control, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.status === -1) {
        showToast('error', resultado.concepto_status)
        datosGenerales.value = null
        adeudos.value = []
        buscado.value = true
        return
      }

      datosGenerales.value = resultado
      buscado.value = true
      showToast('success', 'Concesión encontrada')

      // Buscar adeudos
      await buscarAdeudos(resultado.id_datos)

      // Verificar si tiene pagados
      await verificarPagados(resultado.id_datos)
    } else {
      showToast('error', 'No se encontró la concesión')
      datosGenerales.value = null
      adeudos.value = []
      buscado.value = true
    }
  } catch (error) {
    handleApiError(error)
    datosGenerales.value = null
    adeudos.value = []
    buscado.value = true
  } finally {
    setLoading(false)
  }
}

// Buscar adeudos
const buscarAdeudos = async (idDatos) => {
  const fechaActual = new Date()
  const axoActual = fechaActual.getFullYear()
  const mesActual = 12 // Diciembre por defecto

  try {
    const response = await execute(
      'SP_GADEUDOS_OPC_MULT_ADEUDOS_GET',
      'otras_obligaciones',
      [
        { nombre: 'par_tabla', valor: selectedTabla.value, tipo: 'string' },
        { nombre: 'par_id_datos', valor: idDatos, tipo: 'integer' },
        { nombre: 'par_aso', valor: axoActual, tipo: 'integer' },
        { nombre: 'par_mes', valor: mesActual, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      adeudos.value = response.result.map(a => ({
        ...a,
        seleccionado: false
      }))
      showToast('success', `${adeudos.value.length} adeudo(s) encontrado(s)`)
    } else {
      adeudos.value = []
      showToast('info', 'No se encontraron adeudos')
    }
  } catch (error) {
    handleApiError(error)
    adeudos.value = []
  }
}

// Verificar si tiene pagados
const verificarPagados = async (idDatos) => {
  try {
    const response = await execute(
      'SP_GADEUDOS_OPC_MULT_PAGADOS_GET',
      'otras_obligaciones',
      [
        { nombre: 'p_control', valor: idDatos, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      pagados.value = response.result
      tienePagados.value = true
    } else {
      pagados.value = []
      tienePagados.value = false
    }
  } catch (error) {
    pagados.value = []
    tienePagados.value = false
  }
}

// Ver pagados
const verPagados = () => {
  showPagadosModal.value = true
}

const closePagadosModal = () => {
  showPagadosModal.value = false
}

// Ejecutar acción
const ejecutarAccion = async () => {
  if (adeudosSeleccionados.value.length === 0) {
    showToast('warning', 'Debe seleccionar al menos un adeudo')
    return
  }

  // Obtener el código de status según la opción
  const statusCodes = {
    '1': 'P', // Pagado
    '2': 'S', // Condonado
    '3': 'C', // Cancelado
    '4': 'R'  // Prescrito
  }
  const statusCode = statusCodes[selectedOpcion.value]

  // Construir mensaje de confirmación
  const accionTexto = {
    '1': 'PAGAR',
    '2': 'CONDONAR',
    '3': 'CANCELAR',
    '4': 'PRESCRIBIR'
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: `¿Confirmar ${accionTexto[selectedOpcion.value]} adeudos?`,
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p style="margin-bottom: 10px;">Se procesarán <strong>${adeudosSeleccionados.value.length}</strong> adeudo(s):</p>
        <ul style="list-style: none; padding: 0;">
          <li style="margin: 5px 0;"><strong>Total Importe:</strong> ${formatCurrency(totalImporte.value)}</li>
          <li style="margin: 5px 0;"><strong>Total Recargos:</strong> ${formatCurrency(totalRecargos.value)}</li>
          <li style="margin: 5px 0;"><strong>TOTAL GENERAL:</strong> ${formatCurrency(totalGeneral.value)}</li>
        </ul>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: `Sí, ${accionTexto[selectedOpcion.value].toLowerCase()}`,
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  saving.value = true
  let procesados = 0
  let errores = 0
  const mensajesError = []

  try {
    for (let i = 0; i < adeudosSeleccionados.value.length; i++) {
      const adeudo = adeudosSeleccionados.value[i]

      try {
        const params = [
          { nombre: 'par_id_34_datos', valor: datosGenerales.value.id_datos, tipo: 'integer' },
          { nombre: 'par_axo', valor: adeudo.axo, tipo: 'integer' },
          { nombre: 'par_mes', valor: adeudo.mes, tipo: 'integer' },
          { nombre: 'par_fecha', valor: parametros.value.fechaPago, tipo: 'date' },
          { nombre: 'par_id_rec', valor: parametros.value.recaudadora || 0, tipo: 'integer' },
          { nombre: 'par_caja', valor: parametros.value.caja || '', tipo: 'string' },
          { nombre: 'par_consec', valor: parametros.value.consecutivo || 0, tipo: 'integer' },
          { nombre: 'par_folio_rcbo', valor: parametros.value.folioRecibo || '', tipo: 'string' },
          { nombre: 'par_tab', valor: 'E', tipo: 'string' },
          { nombre: 'par_status', valor: statusCode, tipo: 'string' },
          { nombre: 'par_opc', valor: 'B', tipo: 'string' },
          { nombre: 'par_usuario', valor: 'SISTEMA', tipo: 'string' }
        ]

        const response = await execute(
          'SP_GADEUDOS_OPC_MULT_UPDATE_ADEUDO',
          'otras_obligaciones',
          params,
          'guadalajara'
        )

        if (response && response.result && response.result[0]?.status === 1) {
          procesados++
        } else {
          errores++
          const mensaje = response?.result?.[0]?.concepto_status || 'Error desconocido'
          mensajesError.push(`${adeudo.concepto} ${adeudo.axo}/${adeudo.mes}: ${mensaje}`)
        }
      } catch (error) {
        errores++
        mensajesError.push(`${adeudo.concepto} ${adeudo.axo}/${adeudo.mes}: ${error.message || 'Error al procesar'}`)
      }
    }

    // Mostrar resultado
    if (procesados > 0 && errores === 0) {
      await Swal.fire({
        icon: 'success',
        title: '¡Proceso exitoso!',
        html: `
          <div style="text-align: center;">
            <p style="font-size: 1.1em; margin: 10px 0;">
              Se procesaron correctamente <strong>${procesados}</strong> adeudo(s).
            </p>
          </div>
        `,
        confirmButtonColor: '#ea8215',
        timer: 3000
      })

      showToast('success', `${procesados} adeudo(s) procesado(s)`)

      // Recargar adeudos
      await buscarAdeudos(datosGenerales.value.id_datos)
    } else if (procesados > 0 && errores > 0) {
      await Swal.fire({
        icon: 'warning',
        title: 'Proceso parcial',
        html: `
          <div style="text-align: left; padding: 0 20px;">
            <p><strong>Procesados:</strong> ${procesados}</p>
            <p><strong>Errores:</strong> ${errores}</p>
            <hr>
            <p style="margin-top: 10px;"><strong>Detalles de errores:</strong></p>
            <ul style="max-height: 200px; overflow-y: auto; font-size: 0.9em;">
              ${mensajesError.map(msg => `<li>${msg}</li>`).join('')}
            </ul>
          </div>
        `,
        confirmButtonColor: '#ea8215'
      })

      showToast('warning', `${procesados} procesado(s), ${errores} error(es)`)

      // Recargar adeudos
      await buscarAdeudos(datosGenerales.value.id_datos)
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error al procesar',
        html: `
          <div style="text-align: left; padding: 0 20px;">
            <p>No se pudo procesar ningún adeudo.</p>
            <hr>
            <p style="margin-top: 10px;"><strong>Detalles de errores:</strong></p>
            <ul style="max-height: 200px; overflow-y: auto; font-size: 0.9em;">
              ${mensajesError.map(msg => `<li>${msg}</li>`).join('')}
            </ul>
          </div>
        `,
        confirmButtonColor: '#ea8215'
      })

      showToast('error', 'No se procesaron adeudos')
    }
  } catch (error) {
    handleApiError(error)
    await Swal.fire({
      icon: 'error',
      title: 'Error de conexión',
      text: 'No se pudieron procesar los adeudos',
      confirmButtonColor: '#ea8215'
    })
  } finally {
    saving.value = false
  }
}

// Limpiar búsqueda
const limpiarBusqueda = () => {
  busqueda.value.numExpediente = ''
  busqueda.value.numLocal = ''
  busqueda.value.letra = ''
  datosGenerales.value = null
  adeudos.value = []
  pagados.value = []
  buscado.value = false
  tienePagados.value = false
}

// Lifecycle
onMounted(() => {
  loadTablas()
  loadRecaudadoras()
})
</script>
