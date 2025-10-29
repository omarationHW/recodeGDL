<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="trash-alt" />
      </div>
      <div class="module-view-info">
        <h1>Baja de Registros</h1>
        <p>Otras Obligaciones - Cancelación de contratos/concesiones</p>
      </div>
      <button class="btn-help-icon" @click="openDocumentation" title="Ayuda">
        <font-awesome-icon icon="question-circle" />
      </button>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" @click="goBack">
          <font-awesome-icon icon="arrow-left" /> Salir
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Sección de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            {{ labelBusqueda }}
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="form-row">
            <!-- Campo de búsqueda dinámico según el tipo de tabla -->
            <div class="form-group" v-if="tipoTabla !== 3">
              <label class="municipal-form-label">{{ etiquetaControl }}</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="busqueda.numeroExpediente"
                @keyup.enter="buscarRegistro"
                placeholder="Ingrese número de expediente"
                maxlength="10"
                ref="expedienteInput"
              >
            </div>

            <!-- Para mercados (tipo 3) se usa número de local + letra -->
            <div class="form-group" v-if="tipoTabla === 3">
              <label class="municipal-form-label">Número de Local</label>
              <input
                type="text"
                class="municipal-form-control"
                v-model="busqueda.numeroLocal"
                @keyup.enter="focusLetra"
                placeholder="Número"
                maxlength="3"
                style="width: 150px; display: inline-block; margin-right: 10px;"
                ref="localInput"
              >
              <input
                type="text"
                class="municipal-form-control"
                v-model="busqueda.letra"
                ref="letraInput"
                @keyup.enter="buscarRegistro"
                placeholder="Letra"
                maxlength="1"
                style="width: 80px; display: inline-block;"
              >
            </div>

            <div class="form-group">
              <label class="municipal-form-label">&nbsp;</label>
              <button
                class="btn-municipal-primary"
                @click="buscarRegistro"
                :disabled="loading"
              >
                <font-awesome-icon icon="search" />
                Buscar
              </button>
            </div>
          </div>

          <div class="alert alert-info" v-if="nombreTabla">
            <strong>CANCELACIÓN DE: {{ nombreTabla }}</strong>
          </div>
        </div>
      </div>

      <!-- Panel de datos encontrados -->
      <div class="municipal-card" v-if="registroActual">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Datos del Registro
          </h5>
          <span class="badge" :class="getBadgeClass(registroActual.statusregistro)">
            {{ registroActual.statusregistro }}
          </span>
        </div>

        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <strong>{{ etiquetas.concesionario || 'Concesionario' }}:</strong>
              <span>{{ registroActual.concesionario }}</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.ubicacion || 'Ubicación' }}:</strong>
              <span>{{ registroActual.ubicacion }}</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.nombre_comercial || 'Nombre Comercial' }}:</strong>
              <span>{{ registroActual.nomcomercial }}</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.lugar || 'Lugar' }}:</strong>
              <span>{{ registroActual.lugar }}</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.obs || 'Observaciones' }}:</strong>
              <span>{{ registroActual.obs }}</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.unidad || 'Unidades' }}:</strong>
              <span>{{ registroActual.unidades }}</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.fecha_inicio || 'Fecha Inicio' }}:</strong>
              <span>{{ formatDate(registroActual.fechainicio) }}</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.licencia || 'Licencia' }}:</strong>
              <span>{{ registroActual.licencia }}</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.superficie || 'Superficie' }}:</strong>
              <span>{{ registroActual.superficie }} m²</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.sector || 'Sector' }}:</strong>
              <span>{{ registroActual.sector }}</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.recaudadora || 'Recaudadora' }}:</strong>
              <span>{{ registroActual.recaudadora }}</span>
            </div>
            <div class="info-item">
              <strong>{{ etiquetas.zona || 'Zona' }}:</strong>
              <span>{{ registroActual.zona }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Adeudos y aplicación de baja -->
      <div class="municipal-card" v-if="registroActual && registroActual.statusregistro === 'VIGENTE'">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="exclamation-triangle" />
            Resumen de Adeudos
          </h5>
          <button
            v-if="tienePagos"
            class="btn-municipal-info btn-sm"
            @click="verPagados"
          >
            <font-awesome-icon icon="file-invoice-dollar" />
            Ver Pagos Realizados
          </button>
        </div>

        <div class="municipal-card-body">
          <!-- Tabla de totales por concepto -->
          <div class="table-responsive" v-if="adeudosTotales.length > 0">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Cuenta</th>
                  <th>Obligación</th>
                  <th>Concepto</th>
                  <th class="text-right">Importe</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(total, index) in adeudosTotales" :key="index" class="row-hover">
                  <td>{{ total.cuenta }}</td>
                  <td>{{ total.obliga }}</td>
                  <td>{{ total.concepto }}</td>
                  <td class="text-right">{{ formatCurrency(total.importe) }}</td>
                </tr>
              </tbody>
              <tfoot>
                <tr class="municipal-table-footer">
                  <td colspan="3" class="text-right"><strong>Total a Pagar:</strong></td>
                  <td class="text-right"><strong>{{ formatCurrency(totalGeneral) }}</strong></td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Tabla de detalle de adeudos -->
          <div class="table-responsive mt-3" v-if="adeudosDetalle.length > 0">
            <h6>Detalle por Período</h6>
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Concepto</th>
                  <th>Año</th>
                  <th>Mes</th>
                  <th class="text-right">Importe</th>
                  <th class="text-right">Recargos</th>
                  <th class="text-right">Descuento Imp.</th>
                  <th class="text-right">Descuento Rec.</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(detalle, index) in adeudosDetalle" :key="index" class="row-hover">
                  <td>{{ detalle.concepto }}</td>
                  <td>{{ detalle.axo }}</td>
                  <td>{{ detalle.mes }}</td>
                  <td class="text-right">{{ formatCurrency(detalle.importe_pagar) }}</td>
                  <td class="text-right">{{ formatCurrency(detalle.recargos_pagar) }}</td>
                  <td class="text-right">{{ formatCurrency(detalle.dscto_importe) }}</td>
                  <td class="text-right">{{ formatCurrency(detalle.dscto_recargos) }}</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div v-else class="text-center text-muted">
            <p>No hay adeudos pendientes</p>
          </div>

          <!-- Formulario de aplicación de baja -->
          <div class="baja-form mt-4">
            <h6>
              <font-awesome-icon icon="calendar-alt" />
              Fecha de Cancelación
            </h6>
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Año de Fin</label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="bajaForm.axoFin"
                  min="2000"
                  max="2099"
                  maxlength="4"
                  style="width: 120px;"
                >
              </div>
              <div class="form-group">
                <label class="municipal-form-label">Mes de Fin</label>
                <select class="municipal-form-control" v-model.number="bajaForm.mesFin" style="width: 180px;">
                  <option :value="1">01 - Enero</option>
                  <option :value="2">02 - Febrero</option>
                  <option :value="3">03 - Marzo</option>
                  <option :value="4">04 - Abril</option>
                  <option :value="5">05 - Mayo</option>
                  <option :value="6">06 - Junio</option>
                  <option :value="7">07 - Julio</option>
                  <option :value="8">08 - Agosto</option>
                  <option :value="9">09 - Septiembre</option>
                  <option :value="10">10 - Octubre</option>
                  <option :value="11">11 - Noviembre</option>
                  <option :value="12">12 - Diciembre</option>
                </select>
              </div>
              <div class="form-group">
                <label class="municipal-form-label">&nbsp;</label>
                <button
                  class="btn-municipal-danger"
                  @click="aplicarBaja"
                  :disabled="saving"
                >
                  <font-awesome-icon icon="trash-alt" />
                  {{ saving ? 'Aplicando...' : 'Aplicar Baja' }}
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Mensaje si el registro no está vigente -->
      <div class="municipal-card" v-if="registroActual && registroActual.statusregistro !== 'VIGENTE'">
        <div class="municipal-card-body">
          <div class="alert alert-warning">
            <font-awesome-icon icon="exclamation-triangle" />
            Este registro está en estado <strong>{{ registroActual.statusregistro }}</strong>.
            No se puede aplicar la baja.
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

    <!-- Toast Notifications -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>
  </div>

  <DocumentationModal
    :show="showDocumentation"
    :componentName="'GBaja'"
    :moduleName="'otras_obligaciones'"
    @close="closeDocumentation"
  />

  <!-- Modal de pagos -->
  <ModalPagos
    v-if="showModalPagos"
    :idDatos="registroActual?.id_datos"
    @close="showModalPagos = false"
  />
</template>

<script setup>
import { ref, onMounted, computed, nextTick } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import ModalPagos from '@/components/modules/otras_obligaciones/ModalPagos.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

const router = useRouter()
const route = useRoute()
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

// Referencias
const expedienteInput = ref(null)
const localInput = ref(null)
const letraInput = ref(null)

// Estado
const tipoTabla = ref(route.params.tipo || route.query.tipo || 1) // 1=Tianguis, 2=VíaPública, 3=Mercados, 4=Centrales, 5=Otros
const nombreTabla = ref('')
const etiquetas = ref({})
const registroActual = ref(null)
const adeudosDetalle = ref([])
const adeudosTotales = ref([])
const tienePagos = ref(false)
const saving = ref(false)
const showModalPagos = ref(false)

// Búsqueda
const busqueda = ref({
  numeroExpediente: '',
  numeroLocal: '',
  letra: ''
})

// Formulario de baja
const bajaForm = ref({
  axoFin: new Date().getFullYear(),
  mesFin: 12
})

// Computed
const labelBusqueda = computed(() => {
  return `BUSQUEDA POR: ${etiquetas.value.etiq_control || 'NÚMERO DE CONTROL'}`
})

const etiquetaControl = computed(() => {
  return etiquetas.value.etiq_control || 'Número de Control'
})

const totalGeneral = computed(() => {
  return adeudosTotales.value.reduce((sum, item) => sum + (parseFloat(item.importe) || 0), 0)
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

const getBadgeClass = (status) => {
  switch (status) {
    case 'VIGENTE':
      return 'badge-success'
    case 'SUSPENSION':
      return 'badge-warning'
    case 'CANCELADO':
      return 'badge-danger'
    default:
      return 'badge-secondary'
  }
}

const formatDate = (dateString) => {
  if (!dateString) return '-'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-MX')
  } catch (error) {
    return dateString
  }
}

const formatCurrency = (value) => {
  if (!value) return '$0.00'
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(value)
}

// Cargar etiquetas y tablas
const loadEtiquetas = async () => {
  try {
    const response = await execute(
      'SP_GACTUALIZA_ETIQUETAS_GET',
      'otras_obligaciones',
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'string' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      etiquetas.value = response.result[0]
    }
  } catch (error) {
    console.error('Error al cargar etiquetas:', error)
  }
}

const loadTablas = async () => {
  try {
    const response = await execute(
      'SP_GACTUALIZA_TABLAS_GET',
      'otras_obligaciones',
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'string' }],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      nombreTabla.value = response.result[0].nombre
    }
  } catch (error) {
    console.error('Error al cargar tablas:', error)
  }
}

// Buscar registro
const buscarRegistro = async () => {
  let control = ''

  if (tipoTabla.value === 3) {
    // Mercados: número-letra
    if (!busqueda.value.numeroLocal || busqueda.value.numeroLocal === '0') {
      await Swal.fire({
        icon: 'warning',
        title: 'Campo requerido',
        text: 'Falta el dato del NUMERO DE LOCAL, intentalo de nuevo',
        confirmButtonColor: '#ea8215'
      })
      return
    }
    control = busqueda.value.numeroLocal
    if (busqueda.value.letra) {
      control += '-' + busqueda.value.letra
    }
  } else {
    // Otros tipos: expediente con abreviatura
    if (!busqueda.value.numeroExpediente || busqueda.value.numeroExpediente === '0') {
      await Swal.fire({
        icon: 'warning',
        title: 'Campo requerido',
        text: 'Falta el dato del NUMERO DE EXPEDIENTE, intentalo de nuevo',
        confirmButtonColor: '#ea8215'
      })
      return
    }
    control = (etiquetas.value.abreviatura || '') + busqueda.value.numeroExpediente
  }

  setLoading(true, 'Buscando registro...')

  try {
    const response = await execute(
      'SP_GBAJA_DATOS_GET',
      'otras_obligaciones',
      [
        { nombre: 'par_tab', valor: tipoTabla.value.toString(), tipo: 'string' },
        { nombre: 'par_control', valor: control, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const data = response.result[0]

      if (data.status === -1) {
        await Swal.fire({
          icon: 'info',
          title: 'No encontrado',
          text: data.concepto_status || 'No existe REGISTRO ALGUNO con este dato',
          confirmButtonColor: '#ea8215'
        })
        registroActual.value = null
        adeudosDetalle.value = []
        adeudosTotales.value = []
      } else {
        registroActual.value = data

        if (data.statusregistro !== 'VIGENTE') {
          await Swal.fire({
            icon: 'warning',
            title: 'Registro no vigente',
            text: `REGISTRO EN SUSPENSION O CANCELADO, intentalo de nuevo`,
            confirmButtonColor: '#ea8215'
          })
        } else {
          // Cargar adeudos
          await loadAdeudos()
          await checkPagos()
        }

        showToast('success', 'Registro encontrado')
      }
    } else {
      await Swal.fire({
        icon: 'info',
        title: 'No encontrado',
        text: 'No se encontró ningún registro con ese control',
        confirmButtonColor: '#ea8215'
      })
      registroActual.value = null
    }
  } catch (error) {
    handleApiError(error)
    registroActual.value = null
  } finally {
    setLoading(false)
  }
}

// Cargar adeudos
const loadAdeudos = async () => {
  if (!registroActual.value || !registroActual.value.id_datos) {
    adeudosDetalle.value = []
    adeudosTotales.value = []
    return
  }

  try {
    // Detalle de adeudos
    const responseDetalle = await execute(
      'SP_GBAJA_ADEUDOS_DETALLE',
      'otras_obligaciones',
      [
        { nombre: 'par_tabla', valor: tipoTabla.value.toString(), tipo: 'string' },
        { nombre: 'par_id_datos', valor: registroActual.value.id_datos, tipo: 'integer' },
        { nombre: 'par_aso', valor: bajaForm.value.axoFin, tipo: 'integer' },
        { nombre: 'par_mes', valor: bajaForm.value.mesFin, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (responseDetalle && responseDetalle.result) {
      adeudosDetalle.value = responseDetalle.result
    } else {
      adeudosDetalle.value = []
    }

    // Totales de adeudos
    const responseTotales = await execute(
      'SP_GBAJA_ADEUDOS_TOTALES',
      'otras_obligaciones',
      [
        { nombre: 'par_tabla', valor: tipoTabla.value.toString(), tipo: 'string' },
        { nombre: 'par_id_datos', valor: registroActual.value.id_datos, tipo: 'integer' },
        { nombre: 'par_aso', valor: bajaForm.value.axoFin, tipo: 'integer' },
        { nombre: 'par_mes', valor: bajaForm.value.mesFin, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (responseTotales && responseTotales.result) {
      adeudosTotales.value = responseTotales.result
    } else {
      adeudosTotales.value = []
    }
  } catch (error) {
    console.error('Error al cargar adeudos:', error)
    adeudosDetalle.value = []
    adeudosTotales.value = []
  }
}

// Verificar si tiene pagos
const checkPagos = async () => {
  if (!registroActual.value || !registroActual.value.id_datos) {
    tienePagos.value = false
    return
  }

  try {
    const response = await execute(
      'SP_GBAJA_PAGOS_GET',
      'otras_obligaciones',
      [{ nombre: 'p_Control', valor: registroActual.value.id_datos, tipo: 'integer' }],
      'guadalajara'
    )

    tienePagos.value = response && response.result && response.result.length > 0
  } catch (error) {
    console.error('Error al verificar pagos:', error)
    tienePagos.value = false
  }
}

// Ver pagos
const verPagados = () => {
  showModalPagos.value = true
}

// Aplicar baja
const aplicarBaja = async () => {
  if (!registroActual.value) {
    showToast('error', 'No hay registro seleccionado')
    return
  }

  if (!bajaForm.value.axoFin || !bajaForm.value.mesFin) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Debe especificar el año y mes de finalización',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación con información detallada
  const confirmResult = await Swal.fire({
    icon: 'warning',
    title: '¿Confirmar cancelación?',
    html: `
      <div style="text-align: left; padding: 0 20px;">
        <p><strong>Se dará de baja el siguiente registro:</strong></p>
        <ul style="list-style: none; padding: 0;">
          <li><strong>Concesionario:</strong> ${registroActual.value.concesionario}</li>
          <li><strong>Ubicación:</strong> ${registroActual.value.ubicacion}</li>
          <li><strong>Fecha de fin:</strong> ${bajaForm.value.mesFin}/${bajaForm.value.axoFin}</li>
          <li><strong>Total adeudos:</strong> ${formatCurrency(totalGeneral.value)}</li>
        </ul>
        <p class="text-danger"><strong>Esta acción no se puede revertir.</strong></p>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, dar de baja',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  saving.value = true

  try {
    const response = await execute(
      'SP_GBAJA_APLICAR',
      'otras_obligaciones',
      [
        { nombre: 'par_tabla', valor: tipoTabla.value.toString(), tipo: 'string' },
        { nombre: 'par_id_34_datos', valor: registroActual.value.id_datos, tipo: 'integer' },
        { nombre: 'par_Axo_Fin', valor: bajaForm.value.axoFin, tipo: 'integer' },
        { nombre: 'par_Mes_Fin', valor: bajaForm.value.mesFin, tipo: 'integer' },
        { nombre: 'par_usuario', valor: 'SISTEMA', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]) {
      const data = response.result[0]

      await Swal.fire({
        icon: data.status === 0 ? 'success' : 'error',
        title: data.status === 0 ? 'Baja aplicada' : 'Error',
        text: data.concepto_status,
        confirmButtonColor: '#ea8215'
      })

      if (data.status === 0) {
        // Limpiar formulario y recargar
        registroActual.value = null
        adeudosDetalle.value = []
        adeudosTotales.value = []
        busqueda.value = {
          numeroExpediente: '',
          numeroLocal: '',
          letra: ''
        }
        bajaForm.value = {
          axoFin: new Date().getFullYear(),
          mesFin: 12
        }
      }
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    saving.value = false
  }
}

// Lifecycle
onMounted(async () => {
  await loadEtiquetas()
  await loadTablas()

  // Focus en el campo de búsqueda apropiado
  await nextTick()
  if (tipoTabla.value === 3) {
    localInput.value?.focus()
  } else {
    expedienteInput.value?.focus()
  }
})
</script>
