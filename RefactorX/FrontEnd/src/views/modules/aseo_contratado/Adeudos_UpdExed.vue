<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="boxes-stacked" />
      </div>
      <div class="module-view-info">
        <h1>Actualización de Exedencias</h1>
        <p>Aseo Contratado - Actualizar cantidad y costo de exedencias vigentes</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-secondary" @click="mostrarDocumentacion" title="Documentación Técnica">
          <font-awesome-icon icon="file-code" />
          Documentación
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Panel de Búsqueda -->
      <div class="municipal-card" :class="{ 'panel-disabled': panelActualizacionVisible }">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Búsqueda de Contrato y Exedencia</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Fila 1: Contrato y Tipo Aseo -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Número de Contrato</label>
              <input
                type="number"
                v-model.number="numContrato"
                class="municipal-form-control"
                placeholder="Ingrese número de contrato"
                @keyup.enter="buscarExedencia"
                min="1"
                :disabled="panelActualizacionVisible"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Tipo de Aseo</label>
              <select v-model="tipoAseoSeleccionado" class="municipal-form-control" :disabled="panelActualizacionVisible">
                <option value="">Seleccione tipo de aseo...</option>
                <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
                  {{ tipo.ctrol_aseo }} - {{ tipo.tipo_aseo }} - {{ tipo.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <!-- Fila 2: Ejercicio y Mes -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Ejercicio (Año)</label>
              <input
                type="number"
                v-model.number="ejercicio"
                class="municipal-form-control"
                placeholder="Ej: 2025"
                min="2000"
                max="2099"
                :disabled="panelActualizacionVisible"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Mes</label>
              <select v-model="mesSeleccionado" class="municipal-form-control" :disabled="panelActualizacionVisible">
                <option value="">Seleccione mes...</option>
                <option v-for="mes in meses" :key="mes.value" :value="mes.value">
                  {{ mes.label }}
                </option>
              </select>
            </div>
          </div>

          <!-- Fila 3: Tipo de Operación -->
          <div class="form-row">
            <div class="form-group" style="flex: 0 0 50%;">
              <label class="municipal-form-label required">Tipo de Operación</label>
              <select v-model="tipoOperacionSeleccionado" class="municipal-form-control" :disabled="panelActualizacionVisible">
                <option value="">Seleccione operación...</option>
                <option v-for="op in tiposOperacion" :key="op.ctrol_operacion" :value="op.ctrol_operacion">
                  {{ op.ctrol_operacion }} - {{ op.cve_operacion }} - {{ op.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <!-- Botones de Búsqueda -->
          <div class="button-group mt-3">
            <button
              class="btn-municipal-primary"
              @click="buscarExedencia"
              :disabled="!validarBusqueda() || panelActualizacionVisible"
            >
              <font-awesome-icon icon="search" />
              Buscar Exedencia
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFormulario" :disabled="panelActualizacionVisible">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Panel de Actualización (visible cuando se encuentra exedencia) -->
      <div v-if="panelActualizacionVisible" class="municipal-card mt-3">
        <div class="municipal-card-header bg-warning-subtle">
          <h5><font-awesome-icon icon="edit" /> Actualizar Exedencia</h5>
        </div>
        <div class="municipal-card-body">
          <!-- Info de la exedencia encontrada -->
          <div class="info-row mb-3">
            <div class="info-item">
              <label>Exedencias Actuales:</label>
              <span class="badge bg-info fs-6">{{ exedenciaActual?.exedencias || 0 }}</span>
            </div>
            <div class="info-item">
              <label>Importe Actual:</label>
              <span class="badge bg-secondary fs-6">${{ formatCurrency(exedenciaActual?.importe || 0) }}</span>
            </div>
            <div class="info-item">
              <label>Costo por Exedencia:</label>
              <span class="badge bg-primary fs-6">${{ formatCurrency(costoExed) }}</span>
            </div>
          </div>

          <!-- Campos de actualización -->
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Nueva Cantidad de Exedencias</label>
              <input
                type="number"
                ref="inputCantidad"
                v-model.number="nuevaCantidad"
                class="municipal-form-control"
                placeholder="Ingrese cantidad"
                min="0"
                max="9999"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Número de Oficio</label>
              <input
                type="text"
                v-model="numOficio"
                class="municipal-form-control"
                placeholder="Ingrese número de oficio"
                maxlength="50"
              />
            </div>
          </div>

          <!-- Cálculo del nuevo importe -->
          <div v-if="nuevaCantidad > 0" class="calculo-preview mt-3">
            <div class="calculo-item">
              <span class="calculo-label">Cálculo:</span>
              <span class="calculo-value">{{ nuevaCantidad }} × ${{ formatCurrency(costoExed) }} = <strong>${{ formatCurrency(nuevoImporte) }}</strong></span>
            </div>
          </div>

          <!-- Botones de acción -->
          <div class="button-group mt-3">
            <button
              class="btn-municipal-success"
              @click="ejecutarActualizacion"
              :disabled="!validarActualizacion()"
            >
              <font-awesome-icon icon="check" />
              Actualizar Exedencia
            </button>
            <button class="btn-municipal-secondary" @click="cancelarActualizacion">
              <font-awesome-icon icon="times" />
              Cancelar
            </button>
          </div>
        </div>
      </div>

      <!-- Información/Ayuda -->
      <div class="alert-info-box mt-4">
        <font-awesome-icon icon="info-circle" class="alert-icon" />
        <div class="alert-content">
          <strong>Información:</strong>
          <p>Este módulo permite actualizar la cantidad y el importe de exedencias vigentes.</p>
          <ul>
            <li>Ingrese el número de contrato y seleccione el tipo de aseo</li>
            <li>Especifique el ejercicio (año) y mes del periodo</li>
            <li>Seleccione el tipo de operación (EXCEDENTE, etc.)</li>
            <li>Si existe una exedencia vigente, podrá actualizar la cantidad</li>
            <li>El importe se calcula automáticamente: cantidad × costo por exedencia</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- Modal de Documentación -->
    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Actualización de Exedencias">
      <h3>Actualización de Exedencias</h3>
      <p>Este módulo permite actualizar la cantidad de exedencias (excesos de recolección) para contratos de aseo contratado.</p>

      <h4>Proceso de Actualización:</h4>
      <ol>
        <li>Ingrese el número de contrato</li>
        <li>Seleccione el tipo de aseo correspondiente</li>
        <li>Ingrese el ejercicio (año) del periodo</li>
        <li>Seleccione el mes del periodo</li>
        <li>Seleccione el tipo de operación</li>
        <li>Haga clic en "Buscar Exedencia"</li>
        <li>Si existe una exedencia vigente, ingrese la nueva cantidad</li>
        <li>Ingrese el número de oficio de autorización</li>
        <li>Haga clic en "Actualizar Exedencia"</li>
      </ol>

      <h4>Cálculo del Importe:</h4>
      <p>El importe se calcula automáticamente multiplicando la cantidad de exedencias por el costo por exedencia definido en el contrato.</p>
      <p><strong>Importe = Cantidad × Costo por Exedencia</strong></p>

      <h4>Consideraciones:</h4>
      <ul>
        <li>Solo se pueden actualizar exedencias con status vigente ('V')</li>
        <li>Se requiere un número de oficio de autorización</li>
        <li>Se registra el usuario que realiza la actualización</li>
      </ul>
    </DocumentationModal>

    <!-- Modal de Documentación Técnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Adeudos_UpdExed'"
      :moduleName="'aseo_contratado'"
      @close="showTechDocs = false"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

// Composables
const { execute } = useApi()
const { showToast, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Configuración
const BASE_DB = 'aseo_contratado'
const SCHEMA = 'publico'

// Referencias
const inputCantidad = ref(null)

// Estado de búsqueda
const numContrato = ref(null)
const tipoAseoSeleccionado = ref('')
const ejercicio = ref(new Date().getFullYear())
const mesSeleccionado = ref('')
const tipoOperacionSeleccionado = ref('')

// Estado de actualización
const panelActualizacionVisible = ref(false)
const contratoEncontrado = ref(null)
const exedenciaActual = ref(null)
const costoExed = ref(0)
const nuevaCantidad = ref(0)
const numOficio = ref('')

// Catálogos
const tiposAseo = ref([])
const tiposOperacion = ref([])

// Modales
const showDocumentation = ref(false)
const showTechDocs = ref(false)

// Lista de meses
const meses = [
  { value: '01', label: '01 - Enero' },
  { value: '02', label: '02 - Febrero' },
  { value: '03', label: '03 - Marzo' },
  { value: '04', label: '04 - Abril' },
  { value: '05', label: '05 - Mayo' },
  { value: '06', label: '06 - Junio' },
  { value: '07', label: '07 - Julio' },
  { value: '08', label: '08 - Agosto' },
  { value: '09', label: '09 - Septiembre' },
  { value: '10', label: '10 - Octubre' },
  { value: '11', label: '11 - Noviembre' },
  { value: '12', label: '12 - Diciembre' }
]

// Computed: Nuevo importe calculado
const nuevoImporte = computed(() => {
  return (nuevaCantidad.value || 0) * costoExed.value
})

// Cargar catálogos al montar
onMounted(async () => {
  await cargarCatalogos()
})

// Cargar catálogos de tipos de aseo y operaciones
const cargarCatalogos = async () => {
  showLoading()
  try {
    const [resTiposAseo, resTiposOper] = await Promise.all([
      execute('sp_tipos_aseo_list', BASE_DB, [], '', null, SCHEMA),
      execute('sp_cves_operacion_list', BASE_DB, [], '', null, SCHEMA)
    ])

    tiposAseo.value = resTiposAseo || []
    tiposOperacion.value = resTiposOper || []
  } catch (error) {
    hideLoading()
    console.error('Error cargando catálogos:', error)
    handleApiError(error, 'Error al cargar catálogos')
  } finally {
    hideLoading()
  }
}

// Validar formulario de búsqueda
const validarBusqueda = () => {
  return numContrato.value &&
         tipoAseoSeleccionado.value &&
         ejercicio.value &&
         mesSeleccionado.value &&
         tipoOperacionSeleccionado.value
}

// Validar formulario de actualización
const validarActualizacion = () => {
  return nuevaCantidad.value >= 0 && numOficio.value?.trim()
}

// Buscar exedencia
const buscarExedencia = async () => {
  if (!validarBusqueda()) {
    showToast('Complete todos los campos de búsqueda', 'warning')
    return
  }

  showLoading()
  try {
    // 1. Buscar contrato con costo_exed
    const paramsContrato = [
      { nombre: 'p_num_contrato', valor: numContrato.value, tipo: 'integer' },
      { nombre: 'p_ctrol_aseo', valor: parseInt(tipoAseoSeleccionado.value), tipo: 'integer' },
      { nombre: 'p_ejercicio', valor: ejercicio.value, tipo: 'integer' }
    ]

    const resContrato = await execute(
      'sp_aseo_contrato_buscar_con_costo_exed',
      BASE_DB,
      paramsContrato,
      '',
      null,
      SCHEMA
    )

    if (!resContrato || resContrato.length === 0) {
      hideLoading()
      await Swal.fire({
        title: 'Contrato no encontrado',
        text: 'No existe CONTRATO, intenta con otro',
        icon: 'warning',
        confirmButtonText: 'Aceptar',
        confirmButtonColor: '#dc3545'
      })
      return
    }

    contratoEncontrado.value = resContrato[0]
    costoExed.value = parseFloat(resContrato[0].costo_exed) || 0

    // 2. Buscar exedencia vigente
    const asoMesPago = `${ejercicio.value}-${mesSeleccionado.value}`
    const paramsExed = [
      { nombre: 'p_control_contrato', valor: contratoEncontrado.value.control_contrato, tipo: 'integer' },
      { nombre: 'p_aso_mes_pago', valor: asoMesPago, tipo: 'string' },
      { nombre: 'p_ctrol_operacion', valor: parseInt(tipoOperacionSeleccionado.value), tipo: 'integer' }
    ]

    const resExed = await execute(
      'sp_aseo_buscar_exedencia_vigente',
      BASE_DB,
      paramsExed,
      '',
      null,
      SCHEMA
    )

    hideLoading()

    if (!resExed || resExed.length === 0) {
      await Swal.fire({
        title: 'Exedencia no encontrada',
        text: 'No Existe exedencia en el PERIODO y/o MOVIMIENTO proporcionados ó no está VIGENTE, intenta con otro',
        icon: 'warning',
        confirmButtonText: 'Aceptar',
        confirmButtonColor: '#dc3545'
      })
      return
    }

    // Mostrar panel de actualización
    exedenciaActual.value = resExed[0]
    nuevaCantidad.value = exedenciaActual.value.exedencias || 0
    numOficio.value = ''
    panelActualizacionVisible.value = true

    // Enfocar campo de cantidad
    await nextTick()
    if (inputCantidad.value) {
      inputCantidad.value.focus()
    }

  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al buscar exedencia')
  }
}

// Ejecutar actualización
const ejecutarActualizacion = async () => {
  if (!validarActualizacion()) {
    showToast('Complete los campos requeridos', 'warning')
    return
  }

  // Confirmar acción
  const confirmResult = await Swal.fire({
    title: '¿Confirmar Actualización?',
    html: `
      <p><strong>Contrato:</strong> ${numContrato.value}</p>
      <p><strong>Periodo:</strong> ${ejercicio.value}-${mesSeleccionado.value}</p>
      <p><strong>Nueva Cantidad:</strong> ${nuevaCantidad.value} exedencias</p>
      <p><strong>Nuevo Importe:</strong> $${formatCurrency(nuevoImporte.value)}</p>
      <p><strong>Oficio:</strong> ${numOficio.value}</p>
    `,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Sí, Actualizar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  showLoading()
  try {
    const asoMesPago = `${ejercicio.value}-${mesSeleccionado.value}`
    const params = [
      { nombre: 'p_control_contrato', valor: contratoEncontrado.value.control_contrato, tipo: 'integer' },
      { nombre: 'p_aso_mes_pago', valor: asoMesPago, tipo: 'string' },
      { nombre: 'p_ctrol_operacion', valor: parseInt(tipoOperacionSeleccionado.value), tipo: 'integer' },
      { nombre: 'p_unidades', valor: nuevaCantidad.value, tipo: 'integer' },
      { nombre: 'p_oficio', valor: numOficio.value.trim() || '0', tipo: 'string' },
      { nombre: 'p_usuario', valor: 1, tipo: 'integer' }, // TODO: Obtener usuario real del sistema
      { nombre: 'p_costo_exed', valor: costoExed.value, tipo: 'numeric' }
    ]

    const response = await execute(
      'sp_aseo_actualizar_exedencia',
      BASE_DB,
      params,
      '',
      null,
      SCHEMA
    )

    hideLoading()

    if (response && response.length > 0) {
      const resultado = response[0]
      if (resultado.success) {
        await Swal.fire({
          title: 'Actualización Exitosa',
          text: resultado.message || 'La exedencia se actualizó correctamente.',
          icon: 'success',
          confirmButtonText: 'Aceptar',
          confirmButtonColor: '#28a745'
        })
        limpiarFormulario()
      } else {
        await Swal.fire({
          title: 'Error',
          text: resultado.message || 'Error al actualizar EXEDENCIA..',
          icon: 'error',
          confirmButtonText: 'Aceptar',
          confirmButtonColor: '#dc3545'
        })
      }
    } else {
      showToast('Respuesta inesperada del servidor', 'warning')
    }
  } catch (error) {
    hideLoading()
    hideLoading()
    handleApiError(error, 'Error al actualizar EXEDENCIA..')
  }
}

// Cancelar actualización
const cancelarActualizacion = () => {
  panelActualizacionVisible.value = false
  contratoEncontrado.value = null
  exedenciaActual.value = null
  costoExed.value = 0
  nuevaCantidad.value = 0
  numOficio.value = ''
}

// Limpiar formulario completo
const limpiarFormulario = () => {
  numContrato.value = null
  tipoAseoSeleccionado.value = ''
  ejercicio.value = new Date().getFullYear()
  mesSeleccionado.value = ''
  tipoOperacionSeleccionado.value = ''
  cancelarActualizacion()
}

// Formatear moneda
const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 }).format(value || 0)
}

// Abrir documentación
const openDocumentation = () => {
  showDocumentation.value = true
}

// Mostrar documentación técnica
const mostrarDocumentacion = () => {
  showTechDocs.value = true
}
</script>

