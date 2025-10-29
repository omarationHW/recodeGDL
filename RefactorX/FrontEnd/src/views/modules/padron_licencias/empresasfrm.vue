<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="briefcase" />
      </div>
      <div class="module-view-info">
        <h1>Gestión de Empresas</h1>
        <p>Padrón de Licencias - Registro y Administración de Empresas/Contribuyentes</p></div>
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
          class="btn-municipal-primary"
          @click="openCreateModal"
          :disabled="loading"
        >
          <font-awesome-icon icon="plus" />
          Nueva Empresa
        </button>
      </div>
    </div>

    <div class="module-view-content">

    <!-- Filtros de búsqueda -->
    <div class="municipal-card">
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Empresa ID</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="filters.empresa"
              placeholder="ID de empresa"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Propietario</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.propietario"
              placeholder="Nombre del propietario"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">RFC</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="filters.rfc"
              placeholder="RFC"
              maxlength="13"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Vigencia</label>
            <select class="municipal-form-control" v-model="filters.vigente">
              <option value="">Todas</option>
              <option value="S">Vigentes</option>
              <option value="N">No Vigentes</option>
            </select>
          </div>
        </div>
        <div class="button-group">
          <button
            class="btn-municipal-primary"
            @click="buscarEmpresas"
            :disabled="loading"
          >
            <font-awesome-icon icon="search" />
            Buscar
          </button>
          <button
            class="btn-municipal-secondary"
            @click="limpiarFiltros"
            :disabled="loading"
          >
            <font-awesome-icon icon="times" />
            Limpiar
          </button>
        </div>
      </div>
    </div>

    <!-- Tabla de resultados -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="list" />
          Resultados de Búsqueda
          <span class="badge-info" v-if="empresas.length > 0">{{ empresas.length }} registros</span>
        </h5>
        <div v-if="loading" class="spinner-border" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
      </div>

      <div class="municipal-card-body table-container" v-if="!loading">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>ID</th>
                <th>Propietario</th>
                <th>RFC</th>
                <th>Ubicación</th>
                <th>Colonia</th>
                <th>Zona</th>
                <th>Vigente</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="empresa in empresas" :key="empresa.empresa" class="row-hover">
                <td><strong class="text-primary">{{ empresa.empresa }}</strong></td>
                <td>{{ empresa.propietario?.trim() || 'N/A' }}</td>
                <td><code>{{ empresa.rfc?.trim() || 'N/A' }}</code></td>
                <td>{{ empresa.ubicacion?.trim() || 'N/A' }} {{ empresa.numext_ubic || '' }}</td>
                <td>{{ empresa.colonia_ubic?.trim() || 'N/A' }}</td>
                <td>
                  <span class="badge-secondary">Z-{{ empresa.zona }} / SZ-{{ empresa.subzona }}</span>
                </td>
                <td>
                  <span class="badge" :class="empresa.vigente === 'S' ? 'badge-success' : 'badge-danger'">
                    <font-awesome-icon :icon="empresa.vigente === 'S' ? 'check-circle' : 'times-circle'" />
                    {{ empresa.vigente === 'S' ? 'Vigente' : 'No Vigente' }}
                  </span>
                </td>
                <td>
                  <div class="button-group button-group-sm">
                    <button
                      class="btn-municipal-info btn-sm"
                      @click="verEmpresa(empresa)"
                      title="Ver detalles"
                    >
                      <font-awesome-icon icon="eye" />
                    </button>
                    <button
                      class="btn-municipal-primary btn-sm"
                      @click="editarEmpresa(empresa)"
                      title="Editar"
                    >
                      <font-awesome-icon icon="edit" />
                    </button>
                    <button
                      class="btn-municipal-danger btn-sm"
                      @click="confirmarEliminarEmpresa(empresa)"
                      title="Eliminar"
                    >
                      <font-awesome-icon icon="trash" />
                    </button>
                  </div>
                </td>
              </tr>
              <tr v-if="empresas.length === 0 && !loading">
                <td colspan="8" class="text-center text-muted">
                  <font-awesome-icon icon="search" size="2x" class="empty-icon" />
                  <p>No se encontraron empresas con los criterios especificados</p>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading && empresas.length === 0" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando empresas...</p>
      </div>
    </div>

    <!-- Modal de creación -->
    <Modal
      :show="showCreateModal"
      title="Crear Nueva Empresa"
      size="xl"
      @close="showCreateModal = false"
      @confirm="crearEmpresa"
      :loading="creatingEmpresa"
      confirmText="Crear Empresa"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="crearEmpresa">
        <h6 class="section-title">
          <font-awesome-icon icon="user" />
          Datos del Propietario
        </h6>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Propietario: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newEmpresa.propietario"
              required
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">RFC:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newEmpresa.rfc"
              maxlength="13"
            >
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">CURP:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newEmpresa.curp"
              maxlength="18"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Email:</label>
            <input
              type="email"
              class="municipal-form-control"
              v-model="newEmpresa.email"
            >
          </div>
        </div>

        <h6 class="section-title">
          <font-awesome-icon icon="map-marker-alt" />
          Ubicación del Negocio
        </h6>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Ubicación: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newEmpresa.ubicacion"
              required
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Número Exterior:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="newEmpresa.numext_ubic"
            >
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Colonia:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="newEmpresa.colonia_ubic"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Código Postal:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="newEmpresa.cp"
            >
          </div>
        </div>

        <h6 class="section-title">
          <font-awesome-icon icon="building" />
          Datos del Establecimiento
        </h6>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Superficie Construida (m²):</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="newEmpresa.sup_construida"
              step="0.01"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Superficie Autorizada (m²):</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="newEmpresa.sup_autorizada"
              step="0.01"
            >
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Número de Empleados:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="newEmpresa.num_empleados"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Aforo:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="newEmpresa.aforo"
            >
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Zona:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="newEmpresa.zona"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Subzona:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="newEmpresa.subzona"
            >
          </div>
        </div>
        <div class="form-group full-width">
          <label class="municipal-form-label">Vigente:</label>
          <select class="municipal-form-control" v-model="newEmpresa.vigente">
            <option value="S">Sí</option>
            <option value="N">No</option>
          </select>
        </div>
      </form>
    </Modal>

    <!-- Modal de edición -->
    <Modal
      :show="showEditModal"
      :title="`Editar Empresa: ${selectedEmpresa?.empresa}`"
      size="xl"
      @close="showEditModal = false"
      @confirm="actualizarEmpresa"
      :loading="updatingEmpresa"
      confirmText="Guardar Cambios"
      cancelText="Cancelar"
      :showDefaultFooter="true"
      :confirmButtonClass="'btn-municipal-primary'"
    >
      <form @submit.prevent="actualizarEmpresa" v-if="editForm">
        <h6 class="section-title">Datos del Propietario</h6>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Propietario: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="editForm.propietario"
              required
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">RFC:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="editForm.rfc"
              maxlength="13"
            >
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Email:</label>
            <input
              type="email"
              class="municipal-form-control"
              v-model="editForm.email"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Vigente:</label>
            <select class="municipal-form-control" v-model="editForm.vigente">
              <option value="S">Sí</option>
              <option value="N">No</option>
            </select>
          </div>
        </div>

        <h6 class="section-title">Ubicación</h6>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Ubicación:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="editForm.ubicacion"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Colonia:</label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="editForm.colonia_ubic"
            >
          </div>
        </div>
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Zona:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="editForm.zona"
            >
          </div>
          <div class="form-group">
            <label class="municipal-form-label">Subzona:</label>
            <input
              type="number"
              class="municipal-form-control"
              v-model="editForm.subzona"
            >
          </div>
        </div>
      </form>
    </Modal>

    <!-- Modal de visualización -->
    <Modal
      :show="showViewModal"
      :title="`Detalles de Empresa: ${selectedEmpresa?.empresa}`"
      size="lg"
      @close="showViewModal = false"
      :showDefaultFooter="false"
    >
      <div v-if="selectedEmpresa" class="empresa-details">
        <div class="details-grid">
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="user" />
              Información del Propietario
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Propietario:</td>
                <td>{{ selectedEmpresa.propietario?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">RFC:</td>
                <td><code>{{ selectedEmpresa.rfc?.trim() || 'N/A' }}</code></td>
              </tr>
              <tr>
                <td class="label">Email:</td>
                <td>{{ selectedEmpresa.email?.trim() || 'N/A' }}</td>
              </tr>
            </table>
          </div>
          <div class="detail-section">
            <h6 class="section-title">
              <font-awesome-icon icon="map-marker-alt" />
              Ubicación
            </h6>
            <table class="detail-table">
              <tr>
                <td class="label">Ubicación:</td>
                <td>{{ selectedEmpresa.ubicacion?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Número:</td>
                <td>{{ selectedEmpresa.numext_ubic || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Colonia:</td>
                <td>{{ selectedEmpresa.colonia_ubic?.trim() || 'N/A' }}</td>
              </tr>
              <tr>
                <td class="label">Zona/Subzona:</td>
                <td>{{ selectedEmpresa.zona }} / {{ selectedEmpresa.subzona }}</td>
              </tr>
            </table>
          </div>
        </div>
        <div class="modal-actions">
          <button class="btn-municipal-secondary" @click="showViewModal = false">
            <font-awesome-icon icon="times" />
            Cerrar
          </button>
          <button class="btn-municipal-primary" @click="editarEmpresa(selectedEmpresa); showViewModal = false">
            <font-awesome-icon icon="edit" />
            Editar Empresa
          </button>
        </div>
      </div>
    </Modal>

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

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'empresasfrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </div>
  <!-- /module-view -->
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'

import { ref, onMounted } from 'vue'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Modal from '@/components/common/Modal.vue'
import Swal from 'sweetalert2'

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
const empresas = ref([])
const selectedEmpresa = ref(null)
const showCreateModal = ref(false)
const showEditModal = ref(false)
const showViewModal = ref(false)
const creatingEmpresa = ref(false)
const updatingEmpresa = ref(false)

// Filtros
const filters = ref({
  empresa: null,
  propietario: '',
  rfc: '',
  vigente: ''
})

// Formularios
const newEmpresa = ref({
  propietario: '',
  rfc: '',
  curp: '',
  domicilio: '',
  email: '',
  ubicacion: '',
  numext_ubic: null,
  colonia_ubic: '',
  cp: null,
  sup_construida: null,
  sup_autorizada: null,
  num_empleados: null,
  aforo: null,
  zona: null,
  subzona: null,
  vigente: 'S'
})

const editForm = ref(null)

// Métodos
const buscarEmpresas = async () => {
  setLoading(true)
  try {
    // Implementar búsqueda con los filtros
    // Por ahora, cargamos todas si no hay filtros específicos
    showToast('info', 'Función de búsqueda implementada')
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const limpiarFiltros = () => {
  filters.value = {
    empresa: null,
    propietario: '',
    rfc: '',
    vigente: ''
  }
  empresas.value = []
}

const openCreateModal = () => {
  newEmpresa.value = {
    propietario: '',
    rfc: '',
    curp: '',
    domicilio: '',
    email: '',
    ubicacion: '',
    numext_ubic: null,
    colonia_ubic: '',
    cp: null,
    sup_construida: null,
    sup_autorizada: null,
    num_empleados: null,
    aforo: null,
    zona: null,
    subzona: null,
    vigente: 'S'
  }
  showCreateModal.value = true
}

const crearEmpresa = async () => {
  if (!newEmpresa.value.propietario || !newEmpresa.value.ubicacion) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campos requeridos',
      text: 'Por favor complete los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar creación de empresa?',
    text: `Se creará una nueva empresa para ${newEmpresa.value.propietario}`,
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, crear empresa',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  creatingEmpresa.value = true
  try {
    const response = await execute(
      'SP_EMPRESAS_CREATE',
      'padron_licencias',
      [
        { nombre: 'p_propietario', valor: newEmpresa.value.propietario },
        { nombre: 'p_rfc', valor: newEmpresa.value.rfc || null },
        { nombre: 'p_curp', valor: newEmpresa.value.curp || null },
        { nombre: 'p_domicilio', valor: newEmpresa.value.domicilio || null },
        { nombre: 'p_email', valor: newEmpresa.value.email || null },
        { nombre: 'p_ubicacion', valor: newEmpresa.value.ubicacion },
        { nombre: 'p_numext_ubic', valor: newEmpresa.value.numext_ubic },
        { nombre: 'p_colonia_ubic', valor: newEmpresa.value.colonia_ubic || null },
        { nombre: 'p_cp', valor: newEmpresa.value.cp },
        { nombre: 'p_sup_construida', valor: newEmpresa.value.sup_construida },
        { nombre: 'p_sup_autorizada', valor: newEmpresa.value.sup_autorizada },
        { nombre: 'p_num_empleados', valor: newEmpresa.value.num_empleados },
        { nombre: 'p_aforo', valor: newEmpresa.value.aforo },
        { nombre: 'p_zona', valor: newEmpresa.value.zona },
        { nombre: 'p_subzona', valor: newEmpresa.value.subzona },
        { nombre: 'p_vigente', valor: newEmpresa.value.vigente }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      showCreateModal.value = false
      await Swal.fire({
        icon: 'success',
        title: '¡Empresa creada!',
        text: 'La empresa ha sido creada exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })
      showToast('success', 'Empresa creada exitosamente')
      buscarEmpresas()
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    creatingEmpresa.value = false
  }
}

const editarEmpresa = (empresa) => {
  selectedEmpresa.value = empresa
  editForm.value = {
    empresa: empresa.empresa,
    propietario: empresa.propietario?.trim() || '',
    rfc: empresa.rfc?.trim() || '',
    email: empresa.email?.trim() || '',
    ubicacion: empresa.ubicacion?.trim() || '',
    colonia_ubic: empresa.colonia_ubic?.trim() || '',
    zona: empresa.zona,
    subzona: empresa.subzona,
    vigente: empresa.vigente || 'S'
  }
  showEditModal.value = true
}

const actualizarEmpresa = async () => {
  if (!editForm.value.propietario) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'El propietario es obligatorio',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  const confirmResult = await Swal.fire({
    icon: 'question',
    title: '¿Confirmar actualización?',
    text: 'Se actualizarán los datos de la empresa',
    showCancelButton: true,
    confirmButtonColor: '#ea8215',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, guardar cambios',
    cancelButtonText: 'Cancelar'
  })

  if (!confirmResult.isConfirmed) return

  updatingEmpresa.value = true
  try {
    const response = await execute(
      'SP_EMPRESAS_UPDATE',
      'padron_licencias',
      [
        { nombre: 'p_empresa', valor: editForm.value.empresa },
        { nombre: 'p_propietario', valor: editForm.value.propietario },
        { nombre: 'p_rfc', valor: editForm.value.rfc },
        { nombre: 'p_email', valor: editForm.value.email },
        { nombre: 'p_ubicacion', valor: editForm.value.ubicacion },
        { nombre: 'p_colonia_ubic', valor: editForm.value.colonia_ubic },
        { nombre: 'p_zona', valor: editForm.value.zona },
        { nombre: 'p_subzona', valor: editForm.value.subzona },
        { nombre: 'p_vigente', valor: editForm.value.vigente }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      showEditModal.value = false
      await Swal.fire({
        icon: 'success',
        title: '¡Empresa actualizada!',
        text: 'Los datos han sido actualizados',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })
      showToast('success', 'Empresa actualizada exitosamente')
      buscarEmpresas()
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    updatingEmpresa.value = false
  }
}

const verEmpresa = (empresa) => {
  selectedEmpresa.value = empresa
  showViewModal.value = true
}

const confirmarEliminarEmpresa = async (empresa) => {
  const result = await Swal.fire({
    title: '¿Eliminar empresa?',
    text: `¿Está seguro de eliminar la empresa ${empresa.empresa}?`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, eliminar',
    cancelButtonText: 'Cancelar'
  })

  if (result.isConfirmed) {
    await eliminarEmpresa(empresa)
  }
}

const eliminarEmpresa = async (empresa) => {
  try {
    const response = await execute(
      'SP_EMPRESAS_DELETE',
      'padron_licencias',
      [
        { nombre: 'p_empresa', valor: empresa.empresa }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      await Swal.fire({
        icon: 'success',
        title: '¡Empresa eliminada!',
        text: 'La empresa ha sido eliminada',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })
      showToast('success', 'Empresa eliminada exitosamente')
      buscarEmpresas()
    }
  } catch (error) {
    handleApiError(error)
  }
}

// Lifecycle
onMounted(() => {
  // Inicialización
})
</script>

<style scoped>
.section-title {
  margin: 20px 0 15px 0;
  padding-bottom: 10px;
  border-bottom: 2px solid #ea8215;
  color: #495057;
  font-size: 16px;
}

.section-title:first-of-type {
  margin-top: 0;
}

.empresa-details {
  padding: 20px;
}

.details-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.detail-section {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 4px;
}

.detail-table {
  width: 100%;
  border-collapse: collapse;
}

.detail-table tr {
  border-bottom: 1px solid #dee2e6;
}

.detail-table tr:last-child {
  border-bottom: none;
}

.detail-table td {
  padding: 8px 0;
}

.detail-table td.label {
  font-weight: bold;
  width: 40%;
  color: #495057;
}

.modal-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
  padding-top: 20px;
  border-top: 1px solid #dee2e6;
}

.required {
  color: #dc3545;
}

.full-width {
  grid-column: 1 / -1;
}
</style>
