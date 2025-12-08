<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="hand-holding-dollar" />
      </div>
      <div class="module-view-info">
        <h1>Condonación de Adeudos</h1>
        <p>Aseo Contratado - Condonar adeudos de exedencias vigentes</p>
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
      <!-- Búsqueda de Contrato -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="search" /> Buscar Contrato para Condonar</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Número de Contrato</label>
              <input
                type="number"
                v-model.number="numContrato"
                class="municipal-form-control"
                placeholder="Ingrese número de contrato"
                @keyup.enter="cargarContrato"
                min="1"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Tipo de Aseo</label>
              <select v-model="tipoAseoSeleccionado" class="municipal-form-control">
                <option value="">Seleccione tipo de aseo...</option>
                <option v-for="tipo in tiposAseo" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
                  {{ tipo.tipo_aseo }} - {{ tipo.descripcion }}
                </option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Datos del Periodo a Condonar -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="calendar-alt" /> Periodo a Condonar</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label required">Año</label>
              <input
                type="number"
                v-model.number="anioCondonar"
                class="municipal-form-control"
                placeholder="Ej: 2025"
                min="2000"
                max="2099"
              />
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Mes</label>
              <select v-model="mesCondonar" class="municipal-form-control">
                <option value="">Seleccione mes...</option>
                <option v-for="mes in meses" :key="mes.value" :value="mes.value">
                  {{ mes.label }}
                </option>
              </select>
            </div>
            <div class="form-group">
              <label class="municipal-form-label required">Tipo de Operación</label>
              <select v-model="tipoOperacionSeleccionado" class="municipal-form-control">
                <option value="">Seleccione operación...</option>
                <option v-for="op in tiposOperacion" :key="op.ctrol_operacion" :value="op.ctrol_operacion">
                  {{ op.cve_operacion }} - {{ op.descripcion }}
                </option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Número de Oficio -->
      <div class="municipal-card mt-3">
        <div class="municipal-card-header">
          <h5><font-awesome-icon icon="file-alt" /> Documento de Autorización</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group" style="flex: 0 0 100%;">
              <label class="municipal-form-label required">Número de Oficio</label>
              <input
                type="text"
                v-model="numOficio"
                class="municipal-form-control"
                placeholder="Ingrese el número de oficio de autorización"
                maxlength="50"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Botones de Acción -->
      <div class="button-group mt-3">
        <button
          class="btn-municipal-primary"
          @click="ejecutarCondonacion"
          :disabled="!validarFormulario()"
        >
          <font-awesome-icon icon="check" />
          Ejecutar Condonación
        </button>
        <button class="btn-municipal-secondary" @click="limpiarFormulario">
          <font-awesome-icon icon="eraser" />
          Limpiar
        </button>
      </div>

      <!-- Información/Ayuda -->
      <div class="alert-info-box mt-4">
        <font-awesome-icon icon="info-circle" class="alert-icon" />
        <div class="alert-content">
          <strong>Información:</strong>
          <p>Este módulo permite condonar adeudos de exedencias vigentes (status_vigencia = 'V').</p>
          <ul>
            <li>Ingrese el número de contrato y seleccione el tipo de aseo</li>
            <li>Especifique el año y mes del periodo a condonar</li>
            <li>Seleccione el tipo de operación (normalmente CUOTA NORMAL o EXCEDENTE)</li>
            <li>Ingrese el número de oficio de autorización</li>
            <li>Al condonar, el adeudo cambiará a status 'S' (Condonado)</li>
          </ul>
        </div>
      </div>
    </div>

    <!-- Modal de Documentación -->
    <DocumentationModal :show="showDocumentation" @close="showDocumentation = false" title="Ayuda - Condonación de Adeudos">
      <h3>Condonación de Adeudos</h3>
      <p>Este módulo permite condonar adeudos de exedencias vigentes para contratos de aseo contratado.</p>

      <h4>Proceso de Condonación:</h4>
      <ol>
        <li>Ingrese el número de contrato</li>
        <li>Seleccione el tipo de aseo correspondiente al contrato</li>
        <li>Ingrese el año del periodo a condonar</li>
        <li>Seleccione el mes del periodo</li>
        <li>Seleccione el tipo de operación</li>
        <li>Ingrese el número de oficio de autorización</li>
        <li>Haga clic en "Ejecutar Condonación"</li>
      </ol>

      <h4>Tipos de Operación comunes:</h4>
      <ul>
        <li><strong>CUOTA NORMAL:</strong> Adeudo por cuota mensual regular</li>
        <li><strong>EXCEDENTE:</strong> Adeudo por exceso de recolección</li>
        <li><strong>CONTENEDORES:</strong> Adeudo por uso de contenedores</li>
      </ul>

      <h4>Consideraciones:</h4>
      <ul>
        <li>Solo se pueden condonar adeudos con status vigente ('V')</li>
        <li>Se requiere un número de oficio de autorización</li>
        <li>La condonación es irreversible</li>
        <li>Se registra el usuario y fecha de la condonación</li>
      </ul>
    </DocumentationModal>

    <!-- Modal de Documentación Técnica -->
    <TechnicalDocsModal
      :show="showTechDocs"
      :componentName="'AdeudosCN_Cond'"
      :moduleName="'aseo_contratado'"
      @close="showTechDocs = false"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import Swal from 'sweetalert2'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'

// Composables
const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { showToast, handleApiError } = useLicenciasErrorHandler()

// Configuración
const BASE_DB = 'aseo_contratado'
const SCHEMA = 'public'

// Estado del formulario
const numContrato = ref(null)
const tipoAseoSeleccionado = ref('')
const anioCondonar = ref(new Date().getFullYear())
const mesCondonar = ref('')
const tipoOperacionSeleccionado = ref('')
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

// Cargar catálogos al montar
onMounted(async () => {
  await cargarCatalogos()
})

// Cargar catálogos de tipos de aseo y operaciones
const cargarCatalogos = async () => {
  showLoading()
  try {
    // Cargar ambos catálogos en paralelo
    const [resTiposAseo, resTiposOper] = await Promise.all([
      execute('sp_aseo_tipos_aseo_list', BASE_DB, [], '', null, SCHEMA),
      execute('sp_cves_operacion_list', BASE_DB, [], '', null, SCHEMA)
    ])

    console.log('Tipos Aseo:', resTiposAseo)
    console.log('Tipos Operación:', resTiposOper)

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

// Validar formulario
const validarFormulario = () => {
  return numContrato.value &&
         tipoAseoSeleccionado.value &&
         anioCondonar.value &&
         mesCondonar.value &&
         tipoOperacionSeleccionado.value &&
         numOficio.value?.trim()
}

// Ejecutar condonación
const ejecutarCondonacion = async () => {
  if (!validarFormulario()) {
    showToast('Complete todos los campos obligatorios', 'warning')
    return
  }

  // Confirmar acción
  const confirmResult = await Swal.fire({
    title: '¿Confirmar Condonación?',
    html: `
      <p><strong>Contrato:</strong> ${numContrato.value}</p>
      <p><strong>Tipo Aseo:</strong> ${tipoAseoSeleccionado.value}</p>
      <p><strong>Periodo:</strong> ${anioCondonar.value}-${mesCondonar.value}</p>
      <p><strong>Operación:</strong> ${tipoOperacionSeleccionado.value}</p>
      <p><strong>Oficio:</strong> ${numOficio.value}</p>
      <p class="text-warning mt-2"><strong>Esta acción es irreversible.</strong></p>
    `,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, Condonar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d'
  })

  if (!confirmResult.isConfirmed) {
    return
  }

  showLoading()
  try {
    // Construir el periodo en formato YYYY-MM
    const asoMesPago = `${anioCondonar.value}-${mesCondonar.value}`

    const params = [
      { nombre: 'p_num_contrato', valor: numContrato.value, tipo: 'integer' },
      { nombre: 'p_ctrol_aseo', valor: parseInt(tipoAseoSeleccionado.value), tipo: 'integer' },
      { nombre: 'p_aso_mes_pago', valor: asoMesPago, tipo: 'string' },
      { nombre: 'p_ctrol_operacion', valor: parseInt(tipoOperacionSeleccionado.value), tipo: 'integer' },
      { nombre: 'p_oficio', valor: numOficio.value.trim(), tipo: 'string' },
      { nombre: 'p_usuario', valor: 1, tipo: 'integer' } // TODO: Obtener usuario real del sistema
    ]

    const response = await execute(
      'sp16_condona_adeudo',
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
          title: 'Condonación Exitosa',
          text: resultado.message || 'La condonación se realizó correctamente.',
          icon: 'success',
          confirmButtonText: 'Aceptar',
          confirmButtonColor: '#28a745'
        })
        limpiarFormulario()
      } else {
        await Swal.fire({
          title: 'No se pudo condonar',
          text: resultado.message || 'No existe CONTRATO o EXEDENCIA vigente para condonar.',
          icon: 'warning',
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
    handleApiError(error, 'Error al ejecutar condonación')
  }
}

// Limpiar formulario
const limpiarFormulario = () => {
  numContrato.value = null
  tipoAseoSeleccionado.value = ''
  anioCondonar.value = new Date().getFullYear()
  mesCondonar.value = ''
  tipoOperacionSeleccionado.value = ''
  numOficio.value = ''
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

