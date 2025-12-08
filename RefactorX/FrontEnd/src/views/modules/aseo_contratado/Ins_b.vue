<template>
  <div class="module-view">
        <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="file-import" />
      </div>
      <div class="module-view-info">
        <h1>Inscripción Rápida de Contratos</h1>
        <p>Aseo Contratado - Alta simplificada de nuevos contratos desde catastro</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="mostrarDocumentacion"
          title="Documentacion Tecnica"
        >
          <font-awesome-icon icon="file-code" />
          Documentacion
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
          title="Ayuda"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    
      <button
        type="button"
        class="btn-help-icon"
        @click="mostrarAyuda = true"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>
<div class="municipal-card shadow-sm mb-4">
      <div class="municipal-card-header">
        <h5>Paso 1: Búsqueda en Catastro</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row mb-3">
          <div class="col-md-4">
            <label class="municipal-form-label">Cuenta Catastral *</label>
            <input type="text" class="municipal-form-control" v-model="cuentaCatastral"
              placeholder="Ingrese cuenta catastral (12 dígitos)" maxlength="12"
              @keyup.enter="buscarCatastro" />
          </div>
          <div class="col-md-2">
            <label class="municipal-form-label">&nbsp;</label>
            <button class="btn-municipal-primary w-100" @click="buscarCatastro" :disabled="cargando">
              <font-awesome-icon icon="search" /> Buscar
            </button>
          </div>
        </div>

        <div v-if="datosCatastro" class="municipal-alert municipal-alert-info">
          <h6><font-awesome-icon icon="check-circle" /> Datos del Catastro:</h6>
          <div class="row">
            <div class="col-md-6">
              <p class="mb-1"><strong>Propietario:</strong> {{ datosCatastro.propietario }}</p>
              <p class="mb-1"><strong>Domicilio:</strong> {{ datosCatastro.domicilio }}</p>
            </div>
            <div class="col-md-6">
              <p class="mb-1"><strong>Colonia:</strong> {{ datosCatastro.colonia }}</p>
              <p class="mb-1"><strong>Zona:</strong> {{ datosCatastro.zona }}</p>
            </div>
          </div>
        </div>

        <div v-if="contratoExistente" class="municipal-alert municipal-alert-warning">
          <font-awesome-icon icon="exclamation-triangle" class="me-2" />
          <strong>Atención:</strong> Ya existe un contrato activo para esta cuenta catastral
          (Contrato #{{ contratoExistente.num_contrato }}).
        </div>
      </div>
    </div>

    <div v-if="datosCatastro && !contratoExistente" class="municipal-card">
      <div class="municipal-card-header">
        <h5>Paso 2: Datos del Nuevo Contrato</h5>
      </div>
      <div class="municipal-card-body">
        <div class="row mb-3">
          <div class="col-md-12">
            <h6 class="border-bottom pb-2">Información del Servicio</h6>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Tipo de Aseo *</label>
            <select class="municipal-form-control" v-model="nuevoContrato.tipo_aseo">
              <option value="">Seleccione...</option>
              <option value="D">Doméstico</option>
              <option value="C">Comercial</option>
              <option value="I">Industrial</option>
              <option value="S">Servicios</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Empresa *</label>
            <select class="municipal-form-control" v-model="nuevoContrato.num_empresa">
              <option value="">Seleccione...</option>
              <option v-for="emp in empresas" :key="emp.num_empresa" :value="emp.num_empresa">
                {{ emp.nombre_empresa }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Unidad Recolectora</label>
            <select class="municipal-form-control" v-model="nuevoContrato.num_unidad">
              <option value="">Sin asignar</option>
              <option v-for="u in unidades" :key="u.num_unidad" :value="u.num_unidad">
                {{ u.nombre_unidad }}
              </option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Cuota Mensual *</label>
            <div class="input-group">
              <span class="input-group-text">$</span>
              <input type="number" class="municipal-form-control" v-model.number="nuevoContrato.cuota_mensual"
                step="0.01" min="0" placeholder="0.00" />
            </div>
          </div>
        </div>

        <div class="row mb-3">
          <div class="col-md-12">
            <h6 class="border-bottom pb-2">Datos del Contribuyente</h6>
          </div>
          <div class="col-md-6">
            <label class="municipal-form-label">Nombre del Contribuyente *</label>
            <input type="text" class="municipal-form-control" v-model="nuevoContrato.contribuyente"
              :placeholder="datosCatastro.propietario" />
            <small class="text-muted">Dejar en blanco para usar el propietario catastral</small>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">RFC</label>
            <input type="text" class="municipal-form-control" v-model="nuevoContrato.rfc"
              maxlength="13" style="text-transform: uppercase;" />
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Teléfono</label>
            <input type="text" class="municipal-form-control" v-model="nuevoContrato.telefono"
              placeholder="10 dígitos" />
          </div>
        </div>

        <div class="row mb-3">
          <div class="col-md-12">
            <h6 class="border-bottom pb-2">Configuración Inicial</h6>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Fecha de Alta *</label>
            <input type="date" class="municipal-form-control" v-model="nuevoContrato.fecha_alta" />
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">Periodo Inicial</label>
            <input type="text" class="municipal-form-control" v-model="nuevoContrato.periodo_inicial"
              placeholder="YYYYMM" maxlength="6" />
            <small class="text-muted">Opcional - Se puede asignar después</small>
          </div>
          <div class="col-md-3">
            <label class="municipal-form-label">O Seleccionar Mes</label>
            <input type="month" class="municipal-form-control" @change="actualizarPeriodo" />
          </div>
        </div>

        <div class="row mb-3">
          <div class="col-md-12">
            <label class="municipal-form-label">Observaciones</label>
            <textarea class="municipal-form-control" v-model="nuevoContrato.observaciones" rows="2"
              placeholder="Observaciones adicionales del contrato..."></textarea>
          </div>
        </div>

        <div class="municipal-alert municipal-alert-success">
          <h6><font-awesome-icon icon="info-circle" /> Resumen del Contrato:</h6>
          <ul class="mb-0">
            <li><strong>Cuenta Catastral:</strong> {{ cuentaCatastral }}</li>
            <li><strong>Contribuyente:</strong> {{ nuevoContrato.contribuyente || datosCatastro.propietario }}</li>
            <li><strong>Tipo de Aseo:</strong> {{ formatTipoAseoCompleto(nuevoContrato.tipo_aseo) }}</li>
            <li><strong>Cuota Mensual:</strong> ${{ formatCurrency(nuevoContrato.cuota_mensual) }}</li>
            <li v-if="nuevoContrato.periodo_inicial">
              <strong>Periodo Inicial:</strong> {{ formatPeriodo(nuevoContrato.periodo_inicial) }}
            </li>
          </ul>
        </div>

        <div class="d-flex justify-content-end">
          <button class="btn-municipal-secondary me-2" @click="cancelar">
            <font-awesome-icon icon="times" /> Cancelar
          </button>
          <button class="btn-municipal-primary" @click="guardarContrato"
            :disabled="!validarFormulario()">
            <font-awesome-icon icon="save" /> Guardar Contrato
          </button>
        </div>
      </div>
    </div>

    <DocumentationModal v-if="mostrarAyuda" :show="mostrarAyuda" @close="mostrarAyuda = false"
      title="Inscripción Rápida de Contratos">
      <h6>Descripción</h6>
      <p>Permite dar de alta nuevos contratos de aseo contratado de manera simplificada,
      importando automáticamente los datos desde el padrón catastral.</p>
      <h6>Proceso</h6>
      <ol>
        <li>Buscar la cuenta catastral (debe existir en catastro)</li>
        <li>Verificar que no exista un contrato activo</li>
        <li>Completar los datos del servicio</li>
        <li>Confirmar y guardar</li>
      </ol>
      <h6>Ventajas</h6>
      <ul>
        <li>Importación automática de datos del propietario y domicilio</li>
        <li>Validación de duplicados</li>
        <li>Proceso simplificado y rápido</li>
        <li>Asignación opcional del periodo inicial</li>
      </ul>
      <h6>Datos Requeridos</h6>
      <ul>
        <li>Cuenta catastral válida</li>
        <li>Tipo de aseo</li>
        <li>Empresa prestadora</li>
        <li>Cuota mensual</li>
        <li>Fecha de alta</li>
      </ul>
    </DocumentationModal>
    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'Ins_b'"
      :moduleName="'aseo_contratado'"
      @close="closeTechDocs"
    />

  </div>
</template>

<script setup>
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { ref, onMounted } from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useToast } from '@/composables/useToast'
import Swal from 'sweetalert2'

const { showLoading, hideLoading } = useGlobalLoading()

const { execute } = useApi()
const { handleApiError } = useLicenciasErrorHandler()
const { showToast } = useToast()

const cargando = ref(false)
const mostrarAyuda = ref(false)
const cuentaCatastral = ref('')
const datosCatastro = ref(null)
const contratoExistente = ref(null)
const empresas = ref([])
const unidades = ref([])

const nuevoContrato = ref({
  tipo_aseo: '',
  num_empresa: '',
  num_unidad: '',
  cuota_mensual: 0,
  contribuyente: '',
  rfc: '',
  telefono: '',
  fecha_alta: new Date().toISOString().split('T')[0],
  periodo_inicial: '',
  observaciones: ''
})

const buscarCatastro = async () => {
  if (!cuentaCatastral.value || cuentaCatastral.value.length !== 12) {
    return showToast('Ingrese una cuenta catastral válida (12 dígitos)', 'warning')
  }

  cargando.value = true
  try {
    const params = { p_cuenta_catastral: cuentaCatastral.value }
    const [respCatastro, respContrato] = await Promise.all([
      execute('SP_ASEO_BUSCAR_DATOS_CATASTRO', 'aseo_contratado', params),
      execute('SP_ASEO_VERIFICAR_CONTRATO_EXISTENTE', 'aseo_contratado', params)
    ])

    if (respCatastro && respCatastro.length > 0) {
      datosCatastro.value = respCatastro[0]
      contratoExistente.value = (respContrato && respContrato.length > 0) ? respContrato[0] : null

      if (contratoExistente.value) {
        showToast('Ya existe un contrato para esta cuenta', 'warning')
      } else {
        showToast('Datos cargados desde catastro', 'success')
        // Pre-cargar zona del catastro si está disponible
        if (datosCatastro.value.zona) {
          // La zona ya viene en datosCatastro, se usará al guardar
        }
      }
    } else {
      showToast('Cuenta catastral no encontrada en el padrón', 'error')
      datosCatastro.value = null
    }
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al buscar en catastro')
  } finally {
    cargando.value = false
  }
}

const actualizarPeriodo = (event) => {
  const fecha = event.target.value
  if (fecha) {
    const [anio, mes] = fecha.split('-')
    nuevoContrato.value.periodo_inicial = `${anio}${mes}`
  }
}

const validarFormulario = () => {
  if (!nuevoContrato.value.tipo_aseo) return false
  if (!nuevoContrato.value.num_empresa) return false
  if (!nuevoContrato.value.cuota_mensual || nuevoContrato.value.cuota_mensual <= 0) return false
  if (!nuevoContrato.value.fecha_alta) return false
  return true
}

const guardarContrato = async () => {
  const contribuyenteFinal = nuevoContrato.value.contribuyente || datosCatastro.value.propietario

  const result = await Swal.fire({
    title: '¿Guardar Contrato?',
    html: `Se creará un nuevo contrato para:<br>
           <strong>${contribuyenteFinal}</strong><br>
           Cuenta: ${cuentaCatastral.value}`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonColor: '#198754',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  cargando.value = true
  try {
    const params = {
      p_cuenta_catastral: cuentaCatastral.value,
      p_tipo_aseo: nuevoContrato.value.tipo_aseo,
      p_num_empresa: nuevoContrato.value.num_empresa,
      p_num_unidad: nuevoContrato.value.num_unidad || null,
      p_cuota_mensual: nuevoContrato.value.cuota_mensual,
      p_contribuyente: contribuyenteFinal,
      p_rfc: nuevoContrato.value.rfc || null,
      p_telefono: nuevoContrato.value.telefono || null,
      p_fecha_alta: nuevoContrato.value.fecha_alta,
      p_periodo_inicial: nuevoContrato.value.periodo_inicial || null,
      p_observaciones: nuevoContrato.value.observaciones || null,
      p_zona: datosCatastro.value.zona || null,
      p_colonia: datosCatastro.value.colonia || null,
      p_domicilio: datosCatastro.value.domicilio || null
    }

    const response = await execute('SP_ASEO_INSERTAR_CONTRATO_RAPIDO', 'aseo_contratado', params)

    let mensaje = 'El contrato ha sido creado correctamente'
    if (response && response.length > 0 && response[0].num_contrato) {
      mensaje += `<br><small>Número de contrato: ${response[0].num_contrato}</small>`
    }

    await Swal.fire('¡Guardado!', mensaje, 'success')

    cancelar()
  } catch (error) {
    hideLoading()
    handleApiError(error, 'Error al guardar contrato')
  } finally {
    cargando.value = false
  }
}

const cancelar = () => {
  cuentaCatastral.value = ''
  datosCatastro.value = null
  contratoExistente.value = null
  nuevoContrato.value = {
    tipo_aseo: '',
    num_empresa: '',
    num_unidad: '',
    cuota_mensual: 0,
    contribuyente: '',
    rfc: '',
    telefono: '',
    fecha_alta: new Date().toISOString().split('T')[0],
    periodo_inicial: '',
    observaciones: ''
  }
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('es-MX', { minimumFractionDigits: 2 }).format(value || 0)
}

const formatTipoAseoCompleto = (tipo) => {
  const tipos = { 'D': 'Doméstico', 'C': 'Comercial', 'I': 'Industrial', 'S': 'Servicios' }
  return tipos[tipo] || tipo
}

const formatPeriodo = (periodo) => {
  if (!periodo || periodo.length !== 6) return periodo
  const anio = periodo.substring(0, 4)
  const mes = periodo.substring(4, 6)
  const meses = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
                 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre']
  const mesNombre = meses[parseInt(mes) - 1]
  return `${mesNombre} ${anio}`
}

onMounted(async () => {
  try {
    const [respEmpresas, respUnidades] = await Promise.all([
      execute('SP_ASEO_EMPRESAS_LIST', 'aseo_contratado', {}),
      execute('SP_ASEO_UNIDADES_LIST', 'aseo_contratado', {})
    ])
    empresas.value = respEmpresas || []
    unidades.value = respUnidades || []
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
})

// Documentacion y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false

</script>
