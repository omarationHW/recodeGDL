<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <!-- Header del Módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="plus-circle" />
      </div>
      <div class="module-view-info">
        <h1>Alta de Estacionamiento Público</h1>
        <p>Registro de nuevo contribuyente en el padrón</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-secondary" @click="mostrarDocumentacion" title="Documentación Técnica">
          <font-awesome-icon icon="file-code" /> Documentación
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
      <div class="module-view-actions">
        <button class="btn-municipal-secondary" :disabled="loading" @click="resetForm">
          <font-awesome-icon icon="eraser" /> Limpiar
        </button>
        <button class="btn-municipal-primary" :disabled="loading" @click="create">
          <font-awesome-icon icon="save" /> Registrar
        </button>
      </div>
    </div>

    <!-- Contenido Principal -->
    <div class="module-view-content">
      <div class="form-container">

        <!-- Sección: Consulta de Predio -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-icon">
              <font-awesome-icon icon="search-location" />
            </div>
            <div class="section-title-group">
              <h3>Consulta de Predio</h3>
              <span class="section-subtitle">Opcional - Autocompleta datos desde catastro</span>
            </div>
          </div>
          <div class="section-body">
            <div class="search-row">
              <div class="input-group search-group">
                <span class="input-icon"><font-awesome-icon icon="map-marker-alt" /></span>
                <input
                  type="text"
                  class="municipal-form-control"
                  v-model="claveCatastral"
                  placeholder="Ingrese clave catastral (ej: 001-001-001-001)"
                  @keyup.enter="consultarPredio"
                />
                <button class="btn-municipal-primary" :disabled="loading" @click="consultarPredio">
                  <font-awesome-icon icon="search" /> Buscar
                </button>
              </div>
              <div v-if="predioMsg" class="predio-result">
                <font-awesome-icon icon="check-circle" class="result-icon" />
                <span>{{ predioMsg }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Sección: Datos del Estacionamiento -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-icon">
              <font-awesome-icon icon="car" />
            </div>
            <div class="section-title-group">
              <h3>Datos del Estacionamiento</h3>
              <span class="section-subtitle">Información principal del registro</span>
            </div>
          </div>
          <div class="section-body">
            <div class="form-grid cols-4">
              <div class="form-field">
                <label class="municipal-form-label">Categoría <span class="required">*</span></label>
                <select class="municipal-form-control" v-model.number="form.pubcategoria_id">
                  <option value="">Seleccione categoría...</option>
                  <option v-for="cat in categorias" :key="cat.id" :value="cat.id">
                    {{ cat.descripcion }}
                  </option>
                </select>
              </div>
              <div class="form-field">
                <label class="municipal-form-label">No. Estacionamiento <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="form.numesta" placeholder="Número único" />
              </div>
              <div class="form-field">
                <label class="municipal-form-label">Sector <span class="required">*</span></label>
                <select class="municipal-form-control" v-model="form.sector">
                  <option value="">Seleccione...</option>
                  <option value="J">J - Juárez</option>
                  <option value="H">H - Hidalgo</option>
                  <option value="L">L - Libertad</option>
                  <option value="R">R - Reforma</option>
                </select>
              </div>
              <div class="form-field">
                <label class="municipal-form-label">Cajones (Cupo) <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="form.cupo" placeholder="0" min="1" />
              </div>
            </div>
          </div>
        </div>

        <!-- Sección: Contribuyente -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-icon">
              <font-awesome-icon icon="user-tie" />
            </div>
            <div class="section-title-group">
              <h3>Datos del Contribuyente</h3>
              <span class="section-subtitle">Información del propietario o razón social</span>
            </div>
          </div>
          <div class="section-body">
            <div class="form-grid cols-3">
              <div class="form-field span-2">
                <label class="municipal-form-label">Nombre / Razón Social <span class="required">*</span></label>
                <input type="text" class="municipal-form-control" v-model="form.nombre" placeholder="Nombre completo del contribuyente" />
              </div>
              <div class="form-field">
                <label class="municipal-form-label">RFC</label>
                <input type="text" class="municipal-form-control" v-model="form.rfc" placeholder="XXXX000000XXX" maxlength="13" style="text-transform: uppercase;" />
              </div>
            </div>
            <div class="form-grid cols-3">
              <div class="form-field">
                <label class="municipal-form-label">Teléfono</label>
                <div class="input-with-icon">
                  <font-awesome-icon icon="phone" class="field-icon" />
                  <input type="tel" class="municipal-form-control" v-model="form.telefono" placeholder="33 0000 0000" />
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Sección: Ubicación -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-icon">
              <font-awesome-icon icon="map-marked-alt" />
            </div>
            <div class="section-title-group">
              <h3>Ubicación</h3>
              <span class="section-subtitle">Domicilio del estacionamiento</span>
            </div>
          </div>
          <div class="section-body">
            <div class="form-grid cols-4">
              <div class="form-field span-2">
                <label class="municipal-form-label">Calle</label>
                <input type="text" class="municipal-form-control" v-model="form.calle" placeholder="Nombre de la calle" />
              </div>
              <div class="form-field">
                <label class="municipal-form-label">No. Exterior</label>
                <input type="text" class="municipal-form-control" v-model="form.numext" placeholder="No." />
              </div>
              <div class="form-field">
                <label class="municipal-form-label">Clave Predial</label>
                <input type="number" class="municipal-form-control" v-model.number="form.cvecuenta" placeholder="Cuenta" />
              </div>
            </div>
            <div class="form-grid cols-4">
              <div class="form-field">
                <label class="municipal-form-label">Zona</label>
                <input type="number" class="municipal-form-control" v-model.number="form.zona" placeholder="0" />
              </div>
              <div class="form-field">
                <label class="municipal-form-label">Subzona</label>
                <input type="number" class="municipal-form-control" v-model.number="form.subzona" placeholder="0" />
              </div>
              <div class="form-field">
                <label class="municipal-form-label">No. Licencia</label>
                <input type="number" class="municipal-form-control" v-model.number="form.numlicencia" placeholder="0" />
              </div>
              <div class="form-field">
                <label class="municipal-form-label">Año Licencia</label>
                <input type="number" class="municipal-form-control" v-model.number="form.axolicencias" :placeholder="currentYear.toString()" />
              </div>
            </div>
          </div>
        </div>

        <!-- Sección: Fechas y Control -->
        <div class="form-section">
          <div class="section-header">
            <div class="section-icon">
              <font-awesome-icon icon="calendar-check" />
            </div>
            <div class="section-title-group">
              <h3>Fechas y Control</h3>
              <span class="section-subtitle">Información administrativa del registro</span>
            </div>
          </div>
          <div class="section-body">
            <div class="form-grid cols-4">
              <div class="form-field">
                <label class="municipal-form-label">Fecha de Alta</label>
                <input type="date" class="municipal-form-control" v-model="form.fecha_at" />
              </div>
              <div class="form-field">
                <label class="municipal-form-label">Fecha Inicial</label>
                <input type="date" class="municipal-form-control" v-model="form.fecha_inicial" />
              </div>
              <div class="form-field">
                <label class="municipal-form-label">Fecha Vencimiento</label>
                <input type="date" class="municipal-form-control" v-model="form.fecha_vencimiento" />
              </div>
              <div class="form-field"></div>
            </div>
            <div class="form-grid cols-4">
              <div class="form-field">
                <label class="municipal-form-label">No. Solicitud</label>
                <input type="number" class="municipal-form-control" v-model.number="form.solicitud" placeholder="0" />
              </div>
              <div class="form-field">
                <label class="municipal-form-label">No. Control</label>
                <input type="number" class="municipal-form-control" v-model.number="form.control" placeholder="0" />
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal :show="showDocumentation" @close="closeDocumentation" title="Ayuda - Nuevo Estacionamiento">
      <h3>Alta de Nuevo Estacionamiento Público</h3>
      <p>Este módulo permite registrar nuevos estacionamientos públicos en el sistema.</p>
      <h4>Campos Obligatorios:</h4>
      <ul>
        <li><strong>Categoría:</strong> Tipo de estacionamiento</li>
        <li><strong>No. Estacionamiento:</strong> Número único identificador</li>
        <li><strong>Sector:</strong> J (Juárez), H (Hidalgo), L (Libertad), R (Reforma)</li>
        <li><strong>Cajones:</strong> Capacidad del estacionamiento</li>
        <li><strong>Nombre:</strong> Nombre o razón social del contribuyente</li>
      </ul>
      <h4>Consulta de Predio:</h4>
      <p>Puede ingresar la clave catastral para obtener automáticamente los datos de ubicación del predio.</p>
      <h4>Instrucciones:</h4>
      <ol>
        <li>Opcionalmente consulte el predio por clave catastral</li>
        <li>Complete los campos obligatorios marcados con asterisco (*)</li>
        <li>Verifique los datos ingresados</li>
        <li>Haga clic en "Registrar" para guardar</li>
      </ol>
    </DocumentationModal>

    <!-- Modal de Documentación Técnica -->
    <TechnicalDocsModal :show="showTechDocs" :componentName="'PublicosNew'" :moduleName="'estacionamiento_publico'" @close="closeTechDocs" />
  </div>
</template>

<script setup>
import { reactive, ref, onMounted } from 'vue'
import Swal from 'sweetalert2'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'
const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

const currentYear = new Date().getFullYear()
const today = new Date().toISOString().split('T')[0]

// Estado
const categorias = ref([])
const claveCatastral = ref('')
const predioMsg = ref('')

// Estado inicial del formulario
const initialFormState = {
  pubcategoria_id: '',
  numesta: null,
  sector: '',
  zona: null,
  subzona: null,
  numlicencia: null,
  axolicencias: currentYear,
  cvecuenta: null,
  nombre: '',
  calle: '',
  numext: '',
  telefono: '',
  cupo: null,
  fecha_at: today,
  fecha_inicial: today,
  fecha_vencimiento: '',
  rfc: '',
  movtos_no: 0,
  movto_cve: 'A',
  movto_usr: 1,
  solicitud: 0,
  control: 0
}

const form = reactive({ ...initialFormState })

// Cargar categorías al montar
onMounted(async () => {
  await loadCategorias()
})

/**
 * Carga catálogo de categorías
 */
async function loadCategorias() {
  try {
    const resp = await execute('sp_get_categorias_publicos', BASE_DB, [], '', null, SCHEMA)
    categorias.value = resp?.result || resp?.data?.result || resp?.data || []
  } catch (e) {
    console.error('Error cargando categorías:', e)
    showToast('error', 'Error al cargar categorías')
  }
}

/**
 * Resetea el formulario
 */
function resetForm() {
  Object.assign(form, {
    ...initialFormState,
    fecha_at: today,
    fecha_inicial: today,
    axolicencias: currentYear
  })
  claveCatastral.value = ''
  predioMsg.value = ''
  showToast('info', 'Formulario limpiado')
}

/**
 * Valida campos obligatorios
 */
function validarCamposRequeridos() {
  if (!form.pubcategoria_id) {
    showToast('warning', 'Seleccione una categoría')
    return false
  }
  if (!form.numesta || form.numesta <= 0) {
    showToast('warning', 'Ingrese el número de estacionamiento')
    return false
  }
  if (!form.sector) {
    showToast('warning', 'Seleccione el sector')
    return false
  }
  if (!form.cupo || form.cupo <= 0) {
    showToast('warning', 'Ingrese el número de cajones')
    return false
  }
  if (!form.nombre || form.nombre.trim() === '') {
    showToast('warning', 'Ingrese el nombre del contribuyente')
    return false
  }
  return true
}

/**
 * Consulta predio por clave catastral
 */
async function consultarPredio() {
  if (!claveCatastral.value) {
    showToast('warning', 'Ingrese una clave catastral')
    return
  }

  predioMsg.value = ''

  try {
    showLoading('Consultando...', 'Buscando información del predio')

    const params = [
      { nombre: 'p_opc', valor: 1, tipo: 'integer' },
      { nombre: 'p_dato', valor: claveCatastral.value, tipo: 'string' }
    ]

    const resp = await execute('cons_predio', BASE_DB, params, '', null, SCHEMA)
    const r = resp?.result?.[0] || resp?.data?.result?.[0] || resp?.data?.[0] || null

    if (r && r.cvecuenta) {
      form.cvecuenta = r.cvecuenta || form.cvecuenta
      form.zona = r.zona || form.zona
      form.subzona = r.subzona || form.subzona
      form.calle = r.calle || form.calle
      form.numext = r.numext || form.numext
      if (r.contribuyente && !form.nombre) {
        form.nombre = r.contribuyente
      }
      predioMsg.value = `Predio encontrado: ${r.contribuyente || r.calle || 'Datos cargados'}`
      showToast('success', 'Datos del predio cargados correctamente')
    } else {
      predioMsg.value = ''
      showToast('info', 'No se encontró información del predio con esa clave')
    }
  } catch (e) {
    handleApiError(e)
    predioMsg.value = ''
  } finally {
    hideLoading()
  }
}

/**
 * Crea nuevo estacionamiento
 */
async function create() {
  // Validar campos requeridos
  if (!validarCamposRequeridos()) {
    return
  }

  // Confirmación
  const result = await Swal.fire({
    icon: 'question',
    title: 'Confirmar Alta',
    html: `
      <div style="text-align: left; padding: 0 1rem;">
        <p style="margin-bottom: 1rem;">¿Está seguro de registrar el nuevo estacionamiento?</p>
        <table style="width: 100%; font-size: 0.95rem;">
          <tr><td style="padding: 0.25rem 0; color: #666;">No. Estacionamiento:</td><td style="font-weight: 600;">${form.numesta}</td></tr>
          <tr><td style="padding: 0.25rem 0; color: #666;">Nombre:</td><td style="font-weight: 600;">${form.nombre}</td></tr>
          <tr><td style="padding: 0.25rem 0; color: #666;">Cajones:</td><td style="font-weight: 600;">${form.cupo}</td></tr>
          <tr><td style="padding: 0.25rem 0; color: #666;">Sector:</td><td style="font-weight: 600;">${form.sector}</td></tr>
        </table>
      </div>
    `,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: '<i class="fas fa-check"></i> Sí, registrar',
    cancelButtonText: '<i class="fas fa-times"></i> Cancelar'
  })

  if (!result.isConfirmed) return

  try {
    showLoading('Registrando...', 'Guardando nuevo estacionamiento')

    const params = [
      { nombre: 'p_pubcategoria_id', valor: form.pubcategoria_id, tipo: 'integer' },
      { nombre: 'p_numesta', valor: form.numesta, tipo: 'integer' },
      { nombre: 'p_sector', valor: form.sector, tipo: 'string' },
      { nombre: 'p_zona', valor: form.zona || 0, tipo: 'integer' },
      { nombre: 'p_subzona', valor: form.subzona || 0, tipo: 'integer' },
      { nombre: 'p_numlicencia', valor: form.numlicencia || 0, tipo: 'integer' },
      { nombre: 'p_axolicencias', valor: form.axolicencias || currentYear, tipo: 'integer' },
      { nombre: 'p_cvecuenta', valor: form.cvecuenta || 0, tipo: 'integer' },
      { nombre: 'p_nombre', valor: form.nombre, tipo: 'string' },
      { nombre: 'p_calle', valor: form.calle || '', tipo: 'string' },
      { nombre: 'p_numext', valor: form.numext || '', tipo: 'string' },
      { nombre: 'p_telefono', valor: form.telefono || '', tipo: 'string' },
      { nombre: 'p_cupo', valor: form.cupo, tipo: 'integer' },
      { nombre: 'p_fecha_at', valor: form.fecha_at || today, tipo: 'date' },
      { nombre: 'p_fecha_inicial', valor: form.fecha_inicial || today, tipo: 'date' },
      { nombre: 'p_fecha_vencimiento', valor: form.fecha_vencimiento || null, tipo: 'date' },
      { nombre: 'p_rfc', valor: form.rfc || '', tipo: 'string' },
      { nombre: 'p_movtos_no', valor: form.movtos_no || 0, tipo: 'integer' },
      { nombre: 'p_movto_cve', valor: 'A', tipo: 'string' },
      { nombre: 'p_movto_usr', valor: form.movto_usr || 1, tipo: 'integer' },
      { nombre: 'p_solicitud', valor: form.solicitud || 0, tipo: 'integer' },
      { nombre: 'p_control', valor: form.control || 0, tipo: 'integer' }
    ]

    const resp = await execute('sppubalta', BASE_DB, params, '', null, SCHEMA)
    const r = resp?.result?.[0] || resp?.data?.result?.[0] || resp?.data?.[0] || {}

    if (r?.result === 1) {
      showToast('success', `Estacionamiento registrado correctamente. ID asignado: ${r.idnvo}`)

      // Limpiar formulario después de éxito
      setTimeout(() => {
        resetForm()
      }, 100)
    } else {
      showToast('error', r?.resultstr || 'No se pudo crear el estacionamiento')
    }
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

// Documentación y Ayuda
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false
</script>

<style scoped>
/* Contenedor del formulario */
.form-container {
  padding: 1.5rem;
}

/* Secciones del formulario */
.form-section {
  background: #fff;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  margin-bottom: 1.5rem;
  overflow: hidden;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
}

.form-section:last-child {
  margin-bottom: 0;
}

/* Header de sección */
.section-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.25rem;
  background: linear-gradient(135deg, #f8fafc 0%, #f1f5f9 100%);
  border-bottom: 2px solid #ea8215;
}

.section-icon {
  width: 40px;
  height: 40px;
  background: linear-gradient(135deg, #ea8215 0%, #cc9f52 100%);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-size: 1.1rem;
  flex-shrink: 0;
}

.section-title-group h3 {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 700;
  color: #1e293b;
}

.section-subtitle {
  font-size: 0.85rem;
  color: #64748b;
  margin-top: 0.15rem;
  display: block;
}

/* Body de sección */
.section-body {
  padding: 1.5rem;
}

/* Grid de formulario */
.form-grid {
  display: grid;
  gap: 1.25rem;
  margin-bottom: 1.25rem;
}

.form-grid:last-child {
  margin-bottom: 0;
}

.form-grid.cols-2 {
  grid-template-columns: repeat(2, 1fr);
}

.form-grid.cols-3 {
  grid-template-columns: repeat(3, 1fr);
}

.form-grid.cols-4 {
  grid-template-columns: repeat(4, 1fr);
}

.form-field.span-2 {
  grid-column: span 2;
}

.form-field.span-3 {
  grid-column: span 3;
}

/* Campos del formulario */
.form-field {
  display: flex;
  flex-direction: column;
}

.form-field .municipal-form-label {
  margin-bottom: 0.5rem;
  font-weight: 600;
  color: #334155;
  font-size: 0.9rem;
}

.form-field .required {
  color: #dc3545;
  margin-left: 0.25rem;
}

.form-field .municipal-form-control {
  padding: 0.65rem 0.85rem;
  border: 2px solid #e2e8f0;
  border-radius: 6px;
  font-size: 0.95rem;
  transition: all 0.2s ease;
}

.form-field .municipal-form-control:focus {
  border-color: #ea8215;
  box-shadow: 0 0 0 3px rgba(234, 130, 21, 0.1);
  outline: none;
}

.form-field .municipal-form-control:hover:not(:focus) {
  border-color: #cbd5e1;
}

/* Input con icono */
.input-with-icon {
  position: relative;
}

.input-with-icon .field-icon {
  position: absolute;
  left: 0.85rem;
  top: 50%;
  transform: translateY(-50%);
  color: #94a3b8;
  font-size: 0.9rem;
}

.input-with-icon .municipal-form-control {
  padding-left: 2.5rem;
}

/* Búsqueda de predio */
.search-row {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.search-group {
  display: flex;
  align-items: center;
  gap: 0;
  max-width: 600px;
}

.search-group .input-icon {
  background: linear-gradient(135deg, #ea8215 0%, #cc9f52 100%);
  color: white;
  padding: 0.65rem 1rem;
  border-radius: 6px 0 0 6px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.search-group .municipal-form-control {
  border-radius: 0;
  border-left: none;
  flex: 1;
}

.search-group .btn-municipal-primary {
  border-radius: 0 6px 6px 0;
  padding: 0.65rem 1.25rem;
  white-space: nowrap;
}

.predio-result {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  background: linear-gradient(135deg, rgba(16, 185, 129, 0.1) 0%, rgba(5, 150, 105, 0.1) 100%);
  border-left: 3px solid #10b981;
  border-radius: 0 6px 6px 0;
  color: #047857;
  font-weight: 500;
}

.predio-result .result-icon {
  color: #10b981;
  font-size: 1.1rem;
}

/* Responsive */
@media (max-width: 1024px) {
  .form-grid.cols-4 {
    grid-template-columns: repeat(2, 1fr);
  }

  .form-field.span-2 {
    grid-column: span 2;
  }
}

@media (max-width: 768px) {
  .form-container {
    padding: 1rem;
  }

  .form-grid.cols-2,
  .form-grid.cols-3,
  .form-grid.cols-4 {
    grid-template-columns: 1fr;
  }

  .form-field.span-2,
  .form-field.span-3 {
    grid-column: span 1;
  }

  .section-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.75rem;
  }

  .search-group {
    flex-direction: column;
    max-width: 100%;
  }

  .search-group .input-icon {
    display: none;
  }

  .search-group .municipal-form-control {
    border-radius: 6px;
    border-left: 2px solid #e2e8f0;
  }

  .search-group .btn-municipal-primary {
    border-radius: 6px;
    width: 100%;
  }
}
</style>
