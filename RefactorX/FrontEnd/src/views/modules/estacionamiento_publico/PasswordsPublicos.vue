<template>
  <div class="module-view">
    <!-- Toast Notification -->
    <div v-if="toast.show" class="toast-notification" :class="`toast-${toast.type}`">
      <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
      <span class="toast-message">{{ toast.message }}</span>
      <button class="toast-close" @click="hideToast"><font-awesome-icon icon="times" /></button>
    </div>

    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="users-cog" /></div>
      <div class="module-view-info">
        <h1>Administracion de Usuarios</h1>
        <p>Gestion de usuarios y permisos del sistema</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-secondary" @click="mostrarDocumentacion" title="Documentacion Tecnica">
          <font-awesome-icon icon="file-code" /> Documentacion
        </button>
        <button class="btn-municipal-purple" @click="openDocumentation" title="Ayuda">
          <font-awesome-icon icon="question-circle" /> Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Seccion de Filtros -->
      <div class="form-section">
        <div class="section-header">
          <div class="section-icon"><font-awesome-icon icon="filter" /></div>
          <div class="section-title-group">
            <h3>Filtros de Busqueda</h3>
            <span class="section-subtitle">Buscar usuarios por nombre o login</span>
          </div>
          <div class="section-actions">
            <button class="btn-municipal-success" @click="abrirModalNuevo">
              <font-awesome-icon icon="user-plus" /> Nuevo Usuario
            </button>
          </div>
        </div>
        <div class="section-body">
          <div class="filter-row">
            <div class="filter-field">
              <label class="municipal-form-label">Usuario o Nombre</label>
              <div class="input-group">
                <span class="input-icon"><font-awesome-icon icon="search" /></span>
                <input
                  class="municipal-form-control with-icon"
                  v-model="filtro"
                  placeholder="Buscar..."
                  @keyup.enter="load"
                />
              </div>
            </div>
            <div class="filter-field">
              <label class="municipal-form-label">Estado</label>
              <select class="municipal-form-control" v-model="filtroEstado">
                <option value="">Todos</option>
                <option value="A">Activo</option>
                <option value="I">Inactivo</option>
                <option value="B">Bloqueado</option>
              </select>
            </div>
            <div class="filter-actions">
              <button class="btn-municipal-primary" @click="load" :disabled="loading">
                <font-awesome-icon :icon="loading ? 'spinner' : 'search'" :spin="loading" /> Buscar
              </button>
              <button class="btn-municipal-secondary" @click="limpiarFiltros">
                <font-awesome-icon icon="eraser" /> Limpiar
              </button>
            </div>
          </div>
        </div>
      </div>

      <!-- Seccion de Tabla de Usuarios -->
      <div class="form-section">
        <div class="section-header section-header-info">
          <div class="section-icon"><font-awesome-icon icon="users" /></div>
          <div class="section-title-group">
            <h3>Lista de Usuarios</h3>
            <span class="section-subtitle">{{ usuarios.length }} usuarios encontrados</span>
          </div>
          <div class="section-actions">
            <button class="btn-municipal-secondary btn-sm" @click="load" :disabled="loading">
              <font-awesome-icon icon="sync-alt" :spin="loading" /> Actualizar
            </button>
          </div>
        </div>
        <div class="section-body">
          <div v-if="loading" class="loading-container">
            <font-awesome-icon icon="spinner" spin size="2x" />
            <p>Cargando usuarios...</p>
          </div>
          <div v-else-if="usuarios.length === 0" class="empty-state">
            <font-awesome-icon icon="user-slash" size="3x" />
            <p>No se encontraron usuarios</p>
          </div>
          <div v-else class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID</th>
                  <th>Usuario</th>
                  <th>Nombre</th>
                  <th>Estado</th>
                  <th>Recaudadora</th>
                  <th>Nivel</th>
                  <th class="text-center">Acciones</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="u in paginatedData" :key="u.id_usuario">
                  <td><code class="id-code">{{ u.id_usuario }}</code></td>
                  <td><strong>{{ u.usuario }}</strong></td>
                  <td>{{ u.nombre }}</td>
                  <td>
                    <span :class="getEstadoClass(u.estado)">
                      {{ getEstadoTexto(u.estado) }}
                    </span>
                  </td>
                  <td>{{ u.id_rec || '-' }}</td>
                  <td>
                    <span class="nivel-badge" :class="getNivelClass(u.nivel)">
                      {{ getNivelTexto(u.nivel) }}
                    </span>
                  </td>
                  <td class="text-center">
                    <div class="action-buttons">
                      <button class="btn-action btn-edit" @click="abrirModalEditar(u)" title="Editar">
                        <font-awesome-icon icon="edit" />
                      </button>
                      <button class="btn-action btn-delete" @click="eliminar(u)" title="Eliminar">
                        <font-awesome-icon icon="trash-alt" />
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>

            <!-- Paginacion -->
            <div class="pagination-container" v-if="totalPages > 1">
              <div class="pagination-info">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }} - {{ Math.min(currentPage * itemsPerPage, usuarios.length) }} de {{ usuarios.length }}
              </div>
              <div class="pagination-controls">
                <button @click="changePage(1)" :disabled="currentPage === 1" class="btn-page">
                  <font-awesome-icon icon="angle-double-left" />
                </button>
                <button @click="changePage(currentPage - 1)" :disabled="currentPage === 1" class="btn-page">
                  <font-awesome-icon icon="angle-left" />
                </button>
                <span class="page-indicator">{{ currentPage }} / {{ totalPages }}</span>
                <button @click="changePage(currentPage + 1)" :disabled="currentPage === totalPages" class="btn-page">
                  <font-awesome-icon icon="angle-right" />
                </button>
                <button @click="changePage(totalPages)" :disabled="currentPage === totalPages" class="btn-page">
                  <font-awesome-icon icon="angle-double-right" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal Agregar/Editar Usuario -->
    <div v-if="showModal" class="modal-overlay" @click.self="cerrarModal">
      <div class="modal-container">
        <div class="modal-header">
          <h4>
            <font-awesome-icon :icon="modoEdicion ? 'user-edit' : 'user-plus'" />
            {{ modoEdicion ? 'Editar Usuario' : 'Nuevo Usuario' }}
          </h4>
          <button class="modal-close" @click="cerrarModal">
            <font-awesome-icon icon="times" />
          </button>
        </div>
        <div class="modal-body">
          <div class="form-grid">
            <div class="form-field">
              <label class="municipal-form-label">Usuario <span class="required">*</span></label>
              <input
                class="municipal-form-control"
                v-model="formUsuario.usuario"
                maxlength="10"
                :disabled="modoEdicion"
                placeholder="Login del usuario"
              />
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Nombre Completo <span class="required">*</span></label>
              <input
                class="municipal-form-control"
                v-model="formUsuario.nombre"
                maxlength="50"
                placeholder="Nombre del usuario"
              />
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Estado</label>
              <select class="municipal-form-control" v-model="formUsuario.estado">
                <option value="A">Activo</option>
                <option value="I">Inactivo</option>
                <option value="B">Bloqueado</option>
              </select>
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Recaudadora</label>
              <input
                type="number"
                class="municipal-form-control"
                v-model.number="formUsuario.id_rec"
                placeholder="ID Recaudadora"
              />
            </div>
            <div class="form-field">
              <label class="municipal-form-label">Nivel de Acceso</label>
              <select class="municipal-form-control" v-model.number="formUsuario.nivel">
                <option :value="1">1 - Usuario</option>
                <option :value="2">2 - Supervisor</option>
                <option :value="3">3 - Administrador</option>
                <option :value="9">9 - Super Admin</option>
              </select>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn-municipal-secondary" @click="cerrarModal">
            <font-awesome-icon icon="times" /> Cancelar
          </button>
          <button class="btn-municipal-primary" @click="guardar" :disabled="guardando">
            <font-awesome-icon :icon="guardando ? 'spinner' : 'save'" :spin="guardando" />
            {{ guardando ? 'Guardando...' : 'Guardar' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal :show="showDocumentation" @close="closeDocumentation" title="Ayuda - Administracion de Usuarios">
      <h3>Administracion de Usuarios</h3>
      <p>Este modulo permite gestionar los usuarios del sistema de estacionamientos publicos.</p>
      <h4>Campos:</h4>
      <ul>
        <li><strong>Usuario:</strong> Login unico para acceso al sistema (max 10 caracteres)</li>
        <li><strong>Nombre:</strong> Nombre completo del usuario</li>
        <li><strong>Estado:</strong> A=Activo, I=Inactivo, B=Bloqueado</li>
        <li><strong>Recaudadora:</strong> ID de la recaudadora asignada</li>
        <li><strong>Nivel:</strong> Nivel de permisos (1=Usuario, 2=Supervisor, 3=Admin, 9=SuperAdmin)</li>
      </ul>
      <h4>Operaciones:</h4>
      <ul>
        <li><strong>Nuevo Usuario:</strong> Crea un nuevo registro de usuario</li>
        <li><strong>Editar:</strong> Modifica los datos de un usuario existente</li>
        <li><strong>Eliminar:</strong> Elimina un usuario del sistema</li>
      </ul>
    </DocumentationModal>

    <!-- Modal de Documentacion Tecnica -->
    <TechnicalDocsModal :show="showTechDocs" :componentName="'PasswordsPublicos'" :moduleName="'estacionamiento_publico'" @close="closeTechDocs" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import Swal from 'sweetalert2'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import TechnicalDocsModal from '@/components/common/TechnicalDocsModal.vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'

const BASE_DB = 'estacionamiento_publico'
const SCHEMA = 'publico'

const { loading, execute } = useApi()
const { toast, showToast, hideToast, getToastIcon, handleApiError } = useLicenciasErrorHandler()
const { showLoading, hideLoading } = useGlobalLoading()

// Estado
const filtro = ref('')
const filtroEstado = ref('')
const usuarios = ref([])

// Paginacion
const currentPage = ref(1)
const itemsPerPage = ref(10)

const totalPages = computed(() => Math.ceil(filteredData.value.length / itemsPerPage.value))

const filteredData = computed(() => {
  let data = usuarios.value
  if (filtroEstado.value) {
    data = data.filter(u => u.estado === filtroEstado.value)
  }
  return data
})

const paginatedData = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value
  const end = start + itemsPerPage.value
  return filteredData.value.slice(start, end)
})

function changePage(page) {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
  }
}

// Modal
const showModal = ref(false)
const modoEdicion = ref(false)
const guardando = ref(false)
const formUsuario = ref({
  id_usuario: null,
  usuario: '',
  nombre: '',
  estado: 'A',
  id_rec: 0,
  nivel: 1
})

function abrirModalNuevo() {
  modoEdicion.value = false
  formUsuario.value = {
    id_usuario: null,
    usuario: '',
    nombre: '',
    estado: 'A',
    id_rec: 0,
    nivel: 1
  }
  showModal.value = true
}

function abrirModalEditar(u) {
  modoEdicion.value = true
  formUsuario.value = { ...u }
  showModal.value = true
}

function cerrarModal() {
  showModal.value = false
}

// CRUD
async function load() {
  showLoading('Cargando...', 'Obteniendo usuarios')
  currentPage.value = 1
  try {
    const params = [{ nombre: 'p_usuario', valor: filtro.value || null, tipo: 'string' }]
    const resp = await execute('sp_passwords_list', BASE_DB, params, '', null, SCHEMA)
    const data = resp?.result || resp?.data?.result || resp?.data || []
    usuarios.value = Array.isArray(data) ? data : []

    if (usuarios.value.length === 0) {
      showToast('info', 'No se encontraron usuarios')
    } else {
      showToast('success', `${usuarios.value.length} usuarios cargados`)
    }
  } catch (e) {
    handleApiError(e)
    usuarios.value = []
  } finally {
    hideLoading()
  }
}

async function guardar() {
  if (!formUsuario.value.usuario || !formUsuario.value.nombre) {
    showToast('warning', 'Complete los campos obligatorios')
    return
  }

  // 1. SweetAlert2 de confirmación
  const accion = modoEdicion.value ? 'actualizar' : 'crear'
  const result = await Swal.fire({
    title: modoEdicion.value ? 'Actualizar Usuario' : 'Crear Usuario',
    html: `<p>¿Desea ${accion} el usuario <strong>${formUsuario.value.usuario}</strong>?</p>`,
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: `Sí, ${accion}`,
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#667eea',
    cancelButtonColor: '#6c757d'
  })

  if (!result.isConfirmed) return

  // 2. Loading general
  showLoading(modoEdicion.value ? 'Actualizando...' : 'Creando...', 'Procesando usuario')
  guardando.value = true

  try {
    let params
    let spName

    if (modoEdicion.value) {
      spName = 'sp_passwords_update'
      params = [
        { nombre: 'p_id_usuario', valor: formUsuario.value.id_usuario, tipo: 'integer' },
        { nombre: 'p_usuario', valor: formUsuario.value.usuario, tipo: 'string' },
        { nombre: 'p_nombre', valor: formUsuario.value.nombre, tipo: 'string' },
        { nombre: 'p_estado', valor: formUsuario.value.estado, tipo: 'string' },
        { nombre: 'p_id_rec', valor: formUsuario.value.id_rec || 0, tipo: 'integer' },
        { nombre: 'p_nivel', valor: formUsuario.value.nivel || 1, tipo: 'integer' }
      ]
    } else {
      spName = 'sp_passwords_create'
      params = [
        { nombre: 'p_usuario', valor: formUsuario.value.usuario, tipo: 'string' },
        { nombre: 'p_nombre', valor: formUsuario.value.nombre, tipo: 'string' },
        { nombre: 'p_estado', valor: formUsuario.value.estado, tipo: 'string' },
        { nombre: 'p_id_rec', valor: formUsuario.value.id_rec || 0, tipo: 'integer' },
        { nombre: 'p_nivel', valor: formUsuario.value.nivel || 1, tipo: 'integer' }
      ]
    }

    await execute(spName, BASE_DB, params, '', null, SCHEMA)
    showToast('success', modoEdicion.value ? 'Usuario actualizado correctamente' : 'Usuario creado correctamente')
    cerrarModal()
    await load()
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
    guardando.value = false
  }
}

async function eliminar(u) {
  hideLoading()
  await nextTick()

  const result = await Swal.fire({
    title: 'Eliminar Usuario',
    html: `<p>Esta a punto de eliminar al usuario:</p>
           <p><strong>${u.usuario}</strong> - ${u.nombre}</p>
           <p class="text-danger">Esta accion no se puede deshacer.</p>`,
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Si, Eliminar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d'
  })

  if (!result.isConfirmed) return

  showLoading('Eliminando...', 'Procesando')

  try {
    const params = [{ nombre: 'p_id_usuario', valor: u.id_usuario, tipo: 'integer' }]
    await execute('sp_passwords_delete', BASE_DB, params, '', null, SCHEMA)
    showToast('success', 'Usuario eliminado correctamente')
    await load()
  } catch (e) {
    handleApiError(e)
  } finally {
    hideLoading()
  }
}

function limpiarFiltros() {
  filtro.value = ''
  filtroEstado.value = ''
  currentPage.value = 1
}

// Helpers
function getEstadoTexto(estado) {
  switch (estado) {
    case 'A': return 'Activo'
    case 'I': return 'Inactivo'
    case 'B': return 'Bloqueado'
    default: return estado || '-'
  }
}

function getEstadoClass(estado) {
  switch (estado) {
    case 'A': return 'estado-badge estado-activo'
    case 'I': return 'estado-badge estado-inactivo'
    case 'B': return 'estado-badge estado-bloqueado'
    default: return 'estado-badge'
  }
}

function getNivelTexto(nivel) {
  switch (nivel) {
    case 1: return 'Usuario'
    case 2: return 'Supervisor'
    case 3: return 'Admin'
    case 9: return 'Super'
    default: return nivel || '-'
  }
}

function getNivelClass(nivel) {
  switch (nivel) {
    case 9: return 'nivel-super'
    case 3: return 'nivel-admin'
    case 2: return 'nivel-supervisor'
    default: return 'nivel-usuario'
  }
}

onMounted(load)

// Documentacion
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false
const showTechDocs = ref(false)
const mostrarDocumentacion = () => showTechDocs.value = true
const closeTechDocs = () => showTechDocs.value = false
</script>

<style scoped>
/* Secciones */
.form-section {
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  margin-bottom: 1.5rem;
  overflow: hidden;
}

.section-header {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.section-header-info {
  background: linear-gradient(135deg, #17a2b8 0%, #138496 100%);
}

.section-icon {
  width: 40px;
  height: 40px;
  background: rgba(255,255,255,0.2);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
}

.section-title-group {
  flex: 1;
}

.section-title-group h3 {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
}

.section-subtitle {
  font-size: 0.85rem;
  opacity: 0.9;
}

.section-actions {
  margin-left: auto;
}

.section-body {
  padding: 1.5rem;
}

/* Filtros */
.filter-row {
  display: flex;
  gap: 1.5rem;
  align-items: flex-end;
  flex-wrap: wrap;
}

.filter-field {
  flex: 1;
  min-width: 200px;
}

.filter-field label {
  display: block;
  margin-bottom: 0.5rem;
}

.filter-actions {
  display: flex;
  gap: 0.5rem;
}

.input-group {
  position: relative;
}

.input-icon {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #6c757d;
}

.municipal-form-control.with-icon {
  padding-left: 38px;
}

/* Estados */
.loading-container,
.empty-state {
  text-align: center;
  padding: 3rem;
  color: #6c757d;
}

.loading-container p,
.empty-state p {
  margin-top: 1rem;
}

/* Tabla */
.id-code {
  background: #f8f9fa;
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-family: 'Consolas', monospace;
}

.estado-badge {
  padding: 0.25rem 0.75rem;
  border-radius: 12px;
  font-size: 0.85rem;
  font-weight: 500;
}

.estado-activo {
  background: #d4edda;
  color: #155724;
}

.estado-inactivo {
  background: #e2e3e5;
  color: #383d41;
}

.estado-bloqueado {
  background: #f8d7da;
  color: #721c24;
}

.nivel-badge {
  padding: 0.25rem 0.5rem;
  border-radius: 4px;
  font-size: 0.8rem;
  font-weight: 500;
}

.nivel-usuario { background: #e9ecef; color: #495057; }
.nivel-supervisor { background: #cce5ff; color: #004085; }
.nivel-admin { background: #d4edda; color: #155724; }
.nivel-super { background: #f8d7da; color: #721c24; }

/* Botones de accion */
.action-buttons {
  display: flex;
  gap: 0.5rem;
  justify-content: center;
}

.btn-action {
  width: 32px;
  height: 32px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.btn-edit {
  background: #17a2b8;
  color: white;
}

.btn-edit:hover {
  background: #138496;
  transform: scale(1.1);
}

.btn-delete {
  background: #dc3545;
  color: white;
}

.btn-delete:hover {
  background: #c82333;
  transform: scale(1.1);
}

/* Paginacion */
.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid #e9ecef;
}

.pagination-info {
  color: #6c757d;
  font-size: 0.9rem;
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-page {
  width: 32px;
  height: 32px;
  border: 1px solid #dee2e6;
  background: white;
  border-radius: 4px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s;
}

.btn-page:hover:not(:disabled) {
  background: #667eea;
  border-color: #667eea;
  color: white;
}

.btn-page:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.page-indicator {
  padding: 0 1rem;
  font-weight: 500;
}

/* Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-container {
  background: white;
  border-radius: 12px;
  width: 100%;
  max-width: 600px;
  max-height: 90vh;
  overflow: hidden;
  box-shadow: 0 10px 40px rgba(0,0,0,0.2);
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.25rem 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.modal-header h4 {
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.modal-close {
  background: rgba(255,255,255,0.2);
  border: none;
  color: white;
  width: 32px;
  height: 32px;
  border-radius: 6px;
  cursor: pointer;
  transition: background 0.2s;
}

.modal-close:hover {
  background: rgba(255,255,255,0.3);
}

.modal-body {
  padding: 1.5rem;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  padding: 1rem 1.5rem;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 1rem;
}

@media (max-width: 576px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
}

.form-field label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
}

.required {
  color: #dc3545;
}

/* Botones */
.btn-municipal-success {
  background: linear-gradient(135deg, #28a745 0%, #20c997 100%);
  border: none;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 6px;
  cursor: pointer;
  font-weight: 500;
  transition: all 0.2s;
}

.btn-municipal-success:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(40, 167, 69, 0.3);
}
</style>
