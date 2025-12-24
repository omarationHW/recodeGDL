<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-invoice-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Adeudos</h1>
        <p>{{ tituloTabla }}</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-info" @click="abrirDocumentacion">
          <font-awesome-icon icon="book" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="abrirAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
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
      <!-- Tarjeta de búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            {{ etiquetaBusqueda }}
          </h5>
        </div>

        <div class="municipal-card-body">
          <form @submit.prevent="buscarAdeudos">
            <div class="form-row">
              <!-- Campo expediente (visible para tabla 1,2,4,5) -->
              <div class="form-group" v-if="tipoTabla !== '3'">
                <label class="municipal-form-label">
                  {{ etiquetaControl }} <span class="required">*</span>
                </label>
                <div class="input-with-prefix">
                  <span v-if="etiquetas.abreviatura" class="input-prefix">
                    {{ etiquetas.abreviatura }}
                  </span>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="numExpediente"
                    placeholder="Número de expediente"
                    maxlength="6"
                    required
                  >
                </div>
              </div>

              <!-- Campos para Mercados (tabla 3) -->
              <div class="form-group" v-if="tipoTabla === '3'">
                <label class="municipal-form-label">
                  Número de Local <span class="required">*</span>
                </label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="numLocal"
                  placeholder="Número"
                  maxlength="3"
                  required
                >
              </div>

              <div class="form-group" v-if="tipoTabla === '3'">
                <label class="municipal-form-label">Letra</label>
                <input
                  type="text"
                  class="municipal-form-control input-uppercase"
                  v-model="letraLocal"
                  placeholder="Letra"
                  maxlength="1"
                >
              </div>
            </div>

            <!-- Tipo de consulta: Vencidos o A fecha -->
            <div class="form-row">
              <div class="form-group">
                <label class="municipal-form-label">Tipo de Adeudos <span class="required">*</span></label>
                <select
                  class="municipal-form-control"
                  v-model="tipoAdeudos"
                  @change="onTipoAdeudosChange"
                >
                  <option value="V">Vencidos (a la fecha actual)</option>
                  <option value="A">A una fecha específica</option>
                </select>
              </div>

              <div class="form-group" v-if="tipoAdeudos === 'A'">
                <label class="municipal-form-label">Año <span class="required">*</span></label>
                <input
                  type="number"
                  class="municipal-form-control"
                  v-model.number="anoConsulta"
                  :min="2000"
                  :max="2099"
                  maxlength="4"
                  required
                >
              </div>

              <div class="form-group" v-if="tipoAdeudos === 'A'">
                <label class="municipal-form-label">Mes <span class="required">*</span></label>
                <select class="municipal-form-control" v-model="mesConsulta" required>
                  <option value="01">01 - Enero</option>
                  <option value="02">02 - Febrero</option>
                  <option value="03">03 - Marzo</option>
                  <option value="04">04 - Abril</option>
                  <option value="05">05 - Mayo</option>
                  <option value="06">06 - Junio</option>
                  <option value="07">07 - Julio</option>
                  <option value="08">08 - Agosto</option>
                  <option value="09">09 - Septiembre</option>
                  <option value="10">10 - Octubre</option>
                  <option value="11">11 - Noviembre</option>
                  <option value="12">12 - Diciembre</option>
                </select>
              </div>
            </div>

            <div class="button-group">
              <button
                type="submit"
                class="btn-municipal-primary"
                :disabled="loading"
              >
                <font-awesome-icon icon="search" />
                {{ loading ? 'Buscando...' : 'Buscar Adeudos' }}
              </button>
              <button
                type="button"
                class="btn-municipal-secondary"
                @click="limpiarFormulario"
                :disabled="loading"
              >
                <font-awesome-icon icon="eraser" />
                Limpiar
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Tarjeta de información del contrato -->
      <div class="municipal-card" v-if="datosContrato">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Información del Contrato
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="info-grid">
            <div class="info-item">
              <label>Control:</label>
              <span>{{ datosContrato.control }}</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.concesionario || 'Concesionario' }}:</label>
              <span>{{ datosContrato.concesionario }}</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.ubicacion || 'Ubicación' }}:</label>
              <span>{{ datosContrato.ubicacion }}</span>
            </div>
            <div class="info-item" v-if="tipoTabla !== '5'">
              <label>{{ etiquetas.superficie || 'Superficie' }}:</label>
              <span>{{ datosContrato.superficie }} m²</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.fecha_inicio || 'Fecha Inicio' }}:</label>
              <span>{{ formatDate(datosContrato.fechainicio) }}</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.recaudadora || 'Oficina' }}:</label>
              <span>{{ datosContrato.recaudadora }}</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.sector || 'Sector' }}:</label>
              <span>{{ datosContrato.sector }}</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.zona || 'Zona' }}:</label>
              <span>{{ datosContrato.zona }}</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.licencia || 'Licencia' }}:</label>
              <span>{{ datosContrato.licencia }}</span>
            </div>
            <div class="info-item">
              <label>{{ etiquetas.unidad || 'Unidades' }}:</label>
              <span>{{ datosContrato.unidades }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Botones de impresión -->
      <div class="municipal-card" v-if="adeudosConcentrados.length > 0">
        <div class="municipal-card-body">
          <div class="button-group">
            <button
              class="btn-municipal-primary"
              @click="imprimirConcentrado"
              :disabled="loading"
            >
              <font-awesome-icon icon="print" />
              Imprimir Concentrado
            </button>
            <button
              class="btn-municipal-secondary"
              @click="imprimirDetallado"
              :disabled="loading"
            >
              <font-awesome-icon icon="print" />
              Imprimir Detallado
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla de adeudos concentrados -->
      <div class="municipal-card" v-if="adeudosConcentrados.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Adeudos Concentrados por Concepto
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Concepto</th>
                  <th class="text-right">Adeudos</th>
                  <th class="text-right">Recargos</th>
                  <th class="text-right">Multas</th>
                  <th class="text-right">Actualización</th>
                  <th class="text-right">Gastos</th>
                  <th class="text-right">Total</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(adeudo, index) in adeudosConcentrados" :key="index" class="row-hover">
                  <td>{{ adeudo.concepto }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_adeudos) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_recargos) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_multa) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_actualizacion) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_gastos) }}</td>
                  <td class="text-right font-weight-bold">
                    {{ formatCurrency(calcularTotalFila(adeudo)) }}
                  </td>
                </tr>
              </tbody>
              <tfoot class="municipal-table-footer">
                <tr>
                  <td class="font-weight-bold">TOTAL GENERAL:</td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(totalAdeudos) }}</td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(totalRecargos) }}</td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(totalMultas) }}</td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(totalActualizacion) }}</td>
                  <td class="text-right font-weight-bold">{{ formatCurrency(totalGastos) }}</td>
                  <td class="text-right font-weight-bold fs-5">
                    {{ formatCurrency(totalGeneral) }}
                  </td>
                </tr>
              </tfoot>
            </table>
          </div>

          <!-- Nota especial para Estacionamientos (tabla 5) -->
          <div v-if="tipoTabla === '5'" class="alert-info-legal">
            <p class="legal-text">
              <strong>Nota Legal:</strong> Las cantidades mencionadas corresponden al adeudo que tiene con el Municipio de Guadalajara,
              con fundamento en el artículo 42, 43, 44, 45, 46, 47, y 48 del Reglamento de Estacionamientos en el Municipio de Guadalajara.
              De acuerdo al capítulo I, sección primera, artículo 40 fracción V y VI.<br><br>
              A partir del Sexto día hábil en adelante se harán recargos conforme a las especificaciones de la Ley de Ingresos en vigor, Artículo 69.<br><br>
              En caso de tener duda, aclaración o modificación al respecto de su contrato, deberá de acudir a la Dirección de Estacionamientos Municipales.
              Para mayor comodidad, podrá realizar sus pagos con su número de SERV. A. DE VEHICULOS, en cualquier departamento de Administración de Ingresos,
              o en cualquier centro de recaudación del Municipio de Guadalajara.
            </p>
          </div>
        </div>
      </div>

      <!-- Tabla de adeudos detallados -->
      <div class="municipal-card" v-if="adeudosDetallados.length > 0">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="calendar-alt" />
            Adeudos Detallados por Periodo
          </h5>
        </div>

        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>Concepto / Periodo</th>
                  <th class="text-center">Cant. Recolec.</th>
                  <th class="text-right">Adeudos</th>
                  <th class="text-right">Recargos</th>
                  <th class="text-right">Multas</th>
                  <th class="text-right">Actualización</th>
                  <th class="text-right">Gastos</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(adeudo, index) in adeudosDetallados" :key="index" class="row-hover">
                  <td>{{ adeudo.concepto }}</td>
                  <td class="text-center">{{ adeudo.cant_recolec }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_adeudos) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_recargos) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_multas) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_actualizacion) }}</td>
                  <td class="text-right">{{ formatCurrency(adeudo.importe_gastos) }}</td>
                </tr>
              </tbody>
            </table>
          </div>
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
    :show="showDocModal"
    :componentName="'GAdeudos'"
    :moduleName="'otras_obligaciones'"
    :docType="docType"
    :title="'Gestión de Adeudos'"
    @close="showDocModal = false"
  />
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import Swal from 'sweetalert2'

// Router
const route = useRoute()
const router = useRouter()

// Composables
const showDocModal = ref(false)
const docType = ref('ayuda')

const abrirAyuda = () => {
  docType.value = 'ayuda'
  showDocModal.value = true
}

const abrirDocumentacion = () => {
  docType.value = 'documentacion'
  showDocModal.value = true
}

const { execute } = useApi()
const BASE_DB = 'otras_obligaciones'
const {
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const loading = ref(false)
const tipoTabla = ref(route.params.tabla || route.query.tabla || '1')
const etiquetas = ref({})
const infoTabla = ref({})
const numExpediente = ref('')
const numLocal = ref('')
const letraLocal = ref('')
const tipoAdeudos = ref('V') // V = Vencidos, A = A fecha
const anoConsulta = ref(new Date().getFullYear())
const mesConsulta = ref(String(new Date().getMonth() + 1).padStart(2, '0'))
const datosContrato = ref(null)
const adeudosConcentrados = ref([])
const adeudosDetallados = ref([])
const loadingMessage = ref('Cargando...')

// Computed
const tituloTabla = computed(() => {
  if (infoTabla.value.nombre) {
    return `Relación de Adeudos de: ${infoTabla.value.nombre}`
  }
  return 'Otras Obligaciones - Gestión de Adeudos'
})

const etiquetaBusqueda = computed(() => {
  return etiquetas.value.etiq_control || 'Búsqueda por Control'
})

const etiquetaControl = computed(() => {
  return etiquetas.value.etiq_control || 'Número de Expediente'
})

const totalAdeudos = computed(() => {
  return adeudosConcentrados.value.reduce((sum, item) => sum + (item.importe_adeudos || 0), 0)
})

const totalRecargos = computed(() => {
  return adeudosConcentrados.value.reduce((sum, item) => sum + (item.importe_recargos || 0), 0)
})

const totalMultas = computed(() => {
  return adeudosConcentrados.value.reduce((sum, item) => sum + (item.importe_multa || 0), 0)
})

const totalActualizacion = computed(() => {
  return adeudosConcentrados.value.reduce((sum, item) => sum + (item.importe_actualizacion || 0), 0)
})

const totalGastos = computed(() => {
  return adeudosConcentrados.value.reduce((sum, item) => sum + (item.importe_gastos || 0), 0)
})

const totalGeneral = computed(() => {
  return totalAdeudos.value + totalRecargos.value + totalMultas.value +
         totalActualizacion.value + totalGastos.value
})

// Métodos
const calcularTotalFila = (adeudo) => {
  return (adeudo.importe_adeudos || 0) +
         (adeudo.importe_recargos || 0) +
         (adeudo.importe_multa || 0) +
         (adeudo.importe_actualizacion || 0) +
         (adeudo.importe_gastos || 0)
}

const onTipoAdeudosChange = () => {
  if (tipoAdeudos.value === 'V') {
    // Para vencidos, usar fecha actual
    const now = new Date()
    anoConsulta.value = now.getFullYear()
    mesConsulta.value = String(now.getMonth() + 1).padStart(2, '0')
  }
}

const cargarConfiguracion = async () => {
  loading.value = true
  showLoading('Cargando configuración...')

  try {
    // Cargar etiquetas
    const responseEtiq = await execute(
      'sp_otras_oblig_get_etiquetas',
      BASE_DB,
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'string' }],
      'guadalajara'
    )

    if (responseEtiq && responseEtiq.result && responseEtiq.result.length > 0) {
      etiquetas.value = responseEtiq.result[0]
    }

    // Cargar información de la tabla
    const responseTabla = await execute(
      'sp_otras_oblig_get_tablas',
      BASE_DB,
      [{ nombre: 'par_tab', valor: tipoTabla.value, tipo: 'string' }],
      'guadalajara'
    )

    if (responseTabla && responseTabla.result && responseTabla.result.length > 0) {
      infoTabla.value = responseTabla.result[0]
    }

  } catch (error) {
    handleApiError(error)
  } finally {
    loading.value = false
    hideLoading()
  }
}

const buscarAdeudos = async () => {
  // Validar campos
  if (tipoTabla.value === '3') {
    if (!numLocal.value) {
      await Swal.fire({
        icon: 'warning',
        title: 'Campo requerido',
        text: 'Falta el dato del NUMERO DE LOCAL, inténtalo de nuevo',
        confirmButtonColor: '#ea8215'
      })
      return
    }
  } else {
    if (!numExpediente.value) {
      await Swal.fire({
        icon: 'warning',
        title: 'Campo requerido',
        text: 'Falta el dato del NUMERO DE EXPEDIENTE, inténtalo de nuevo',
        confirmButtonColor: '#ea8215'
      })
      return
    }
  }

  if (tipoAdeudos.value === 'A' && !anoConsulta.value) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Falta el dato del AÑO a consultar, inténtalo de nuevo',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Construir número de control (trim para quitar espacios de la abreviatura)
  let control = ''
  if (tipoTabla.value === '3') {
    control = letraLocal.value ? `${numLocal.value}-${letraLocal.value}` : String(numLocal.value)
  } else {
    const abrev = (etiquetas.value.abreviatura || '').trim()
    control = `${abrev}${String(numExpediente.value).trim()}`
  }

  loading.value = true
  showLoading('Buscando contrato...')

  try {
    // Buscar datos del contrato con SP correcto: spcob34_gdatosg_02
    const responseDatos = await execute(
      'spcob34_gdatosg_02',
      BASE_DB,
      [
        { nombre: 'par_tab', valor: tipoTabla.value, tipo: 'string' },
        { nombre: 'par_control', valor: control, tipo: 'string' }
      ],
      'guadalajara'
    )

    // Validar respuesta completa
    if (!responseDatos || !responseDatos.result || responseDatos.result.length === 0 || responseDatos.result[0]?.status === -1) {
      loading.value = false
      hideLoading()
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'No existe REGISTRO ALGUNO con este dato, inténtalo de nuevo',
        confirmButtonColor: '#ea8215'
      })
      datosContrato.value = null
      adeudosConcentrados.value = []
      adeudosDetallados.value = []
      return
    }

    datosContrato.value = responseDatos.result[0]

    // Validar que tenemos id_datos
    if (!datosContrato.value || !datosContrato.value.id_datos) {
      loading.value = false
      hideLoading()
      await Swal.fire({
        icon: 'error',
        title: 'Error de datos',
        text: 'No se pudo obtener el ID del contrato',
        confirmButtonColor: '#ea8215'
      })
      return
    }

    // Construir parámetro de fecha
    const fechaParam = `${anoConsulta.value}-${mesConsulta.value}`

    // Preguntar al usuario qué tipo de reporte desea
    loading.value = false
    hideLoading()
    const tipoReporte = await Swal.fire({
      icon: 'question',
      title: '¿Qué tipo de reporte desea?',
      text: 'Seleccione el formato de estado de cuenta',
      showDenyButton: true,
      showCancelButton: true,
      confirmButtonText: 'Concentrado',
      denyButtonText: 'Detallado',
      cancelButtonText: 'Ambos',
      confirmButtonColor: '#ea8215',
      denyButtonColor: '#6c757d',
      cancelButtonColor: '#0d6efd'
    })

    // Si el usuario cerró el diálogo (ESC o click afuera), cancelar
    if (tipoReporte.isDismissed && tipoReporte.dismiss !== Swal.DismissReason.cancel) {
      return
    }

    // Determinar qué cargar
    const cargarConcentrado = tipoReporte.isConfirmed || tipoReporte.dismiss === Swal.DismissReason.cancel
    const cargarDetallado = tipoReporte.isDenied || tipoReporte.dismiss === Swal.DismissReason.cancel

    loading.value = true
    showLoading('Cargando adeudos...')

    // Cargar concentrado
    if (cargarConcentrado) {
      const responseConcentrado = await execute(
        'con34_gdetade_01',
        BASE_DB,
        [
          { nombre: 'par_tab', valor: parseInt(tipoTabla.value), tipo: 'integer' },
          { nombre: 'par_control', valor: datosContrato.value.id_datos, tipo: 'integer' },
          { nombre: 'par_rep', valor: tipoAdeudos.value, tipo: 'string' },
          { nombre: 'par_fecha', valor: fechaParam, tipo: 'string' }
        ],
        'guadalajara'
      )

      if (responseConcentrado && responseConcentrado.result) {
        adeudosConcentrados.value = responseConcentrado.result.filter(r => r.concepto)
      } else {
        adeudosConcentrados.value = []
      }
    }

    // Cargar detallado
    if (cargarDetallado) {
      const responseDetallado = await execute(
        'con34_gdetade_02',
        BASE_DB,
        [
          { nombre: 'par_tab', valor: parseInt(tipoTabla.value), tipo: 'integer' },
          { nombre: 'par_control', valor: datosContrato.value.id_datos, tipo: 'integer' },
          { nombre: 'par_rep', valor: tipoAdeudos.value, tipo: 'string' },
          { nombre: 'par_fecha', valor: fechaParam, tipo: 'string' }
        ],
        'guadalajara'
      )

      if (responseDetallado && responseDetallado.result) {
        adeudosDetallados.value = responseDetallado.result.filter(r => r.concepto)
      } else {
        adeudosDetallados.value = []
      }
    }

    // Ocultar loading antes de mostrar resultado
    loading.value = false
    hideLoading()

    if (adeudosConcentrados.value.length === 0 && adeudosDetallados.value.length === 0) {
      await Swal.fire({
        icon: 'info',
        title: 'Sin adeudos',
        text: 'No se encontraron adeudos para este contrato con los criterios especificados',
        confirmButtonColor: '#ea8215'
      })
    } else {
      showToast('success', 'Adeudos cargados correctamente')
    }

  } catch (error) {
    handleApiError(error)
    datosContrato.value = null
    adeudosConcentrados.value = []
    adeudosDetallados.value = []
  } finally {
    loading.value = false
    hideLoading()
  }
}

const imprimirConcentrado = async () => {
  const result = await Swal.fire({
    icon: 'question',
    title: 'Imprimir Estado de Cuenta Concentrado',
    text: '¿Desea imprimir el estado de cuenta concentrado?',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, imprimir',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    // Aquí iría la lógica de impresión/generación de PDF
    await Swal.fire({
      icon: 'info',
      title: 'Funcionalidad en desarrollo',
      text: 'La impresión de reportes estará disponible próximamente',
      confirmButtonColor: '#ea8215'
    })
  }
}

const imprimirDetallado = async () => {
  const result = await Swal.fire({
    icon: 'question',
    title: 'Imprimir Estado de Cuenta Detallado',
    text: '¿Desea imprimir el estado de cuenta detallado?',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, imprimir',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    // Aquí iría la lógica de impresión/generación de PDF
    await Swal.fire({
      icon: 'info',
      title: 'Funcionalidad en desarrollo',
      text: 'La impresión de reportes estará disponible próximamente',
      confirmButtonColor: '#ea8215'
    })
  }
}

const limpiarFormulario = () => {
  numExpediente.value = ''
  numLocal.value = ''
  letraLocal.value = ''
  datosContrato.value = null
  adeudosConcentrados.value = []
  adeudosDetallados.value = []
  tipoAdeudos.value = 'V'
  const now = new Date()
  anoConsulta.value = now.getFullYear()
  mesConsulta.value = String(now.getMonth() + 1).padStart(2, '0')
}

const goBack = () => {
  router.push('/otras_obligaciones')
}

// Utilidades
const formatDate = (dateString) => {
  if (!dateString) return ''
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-MX', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return dateString
  }
}

const formatCurrency = (value) => {
  if (!value && value !== 0) return '$0.00'
  try {
    return new Intl.NumberFormat('es-MX', {
      style: 'currency',
      currency: 'MXN'
    }).format(value)
  } catch (error) {
    return `$${value}`
  }
}

// Lifecycle
onMounted(() => {
  cargarConfiguracion()
})
</script>

