<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="user-shield" />
      </div>
      <div class="module-view-info">
        <h1>Privilegios de Usuarios</h1>
        <p>Padrón de Licencias - Consulta de Permisos y Auditoría de Usuarios</p></div>
      <button
        type="button"
        class="btn-help-icon"
        @click="openDocumentation"
        title="Ayuda"
      >
        <font-awesome-icon icon="question-circle" />
      </button>
    </div>

    <div class="module-view-content">

    <!-- Búsqueda de Usuario -->
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="search" />
          Buscar Usuario
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="form-row">
          <div class="form-group">
            <label class="municipal-form-label">Nombre de Usuario: <span class="required">*</span></label>
            <input
              type="text"
              class="municipal-form-control"
              v-model="searchUsuario"
              placeholder="Ingrese nombre de usuario"
              @keyup.enter="buscarPrivilegios"
            >
          </div>
          <div class="form-group">
            <button
              class="btn-municipal-primary"
              @click="buscarPrivilegios"
              :disabled="loading || !searchUsuario"
              style="margin-top: 24px;"
            >
              <font-awesome-icon icon="search" />
              Buscar
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Información del Usuario -->
    <div v-if="usuarioEncontrado" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="user" />
          Información del Usuario
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="user-info-grid">
          <div class="info-item">
            <label>Usuario:</label>
            <strong>{{ usuarioEncontrado.usuario }}</strong>
          </div>
          <div class="info-item">
            <label>Nombre Completo:</label>
            <strong>{{ usuarioEncontrado.nombre_completo || 'N/A' }}</strong>
          </div>
          <div class="info-item">
            <label>Departamento:</label>
            <strong>{{ usuarioEncontrado.departamento || 'N/A' }}</strong>
          </div>
          <div class="info-item">
            <label>Nivel:</label>
            <span class="badge-primary">Nivel {{ usuarioEncontrado.nivel || 'N/A' }}</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Permisos del Usuario -->
    <div v-if="permisos.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="shield-alt" />
          Permisos del Usuario
          <span class="badge-info">{{ permisos.length }} permisos</span>
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Módulo</th>
                <th>Permiso</th>
                <th>Descripción</th>
                <th>Estado</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="permiso in permisos" :key="permiso.id" class="row-hover">
                <td><strong class="text-primary">{{ permiso.modulo || 'N/A' }}</strong></td>
                <td>{{ permiso.permiso || 'N/A' }}</td>
                <td>{{ permiso.descripcion || 'N/A' }}</td>
                <td>
                  <span class="badge-success" v-if="permiso.activo">
                    <font-awesome-icon icon="check-circle" />
                    Activo
                  </span>
                  <span class="badge-secondary" v-else>
                    <font-awesome-icon icon="times-circle" />
                    Inactivo
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Departamentos Asignados -->
    <div v-if="departamentos.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="building" />
          Departamentos Asignados
          <span class="badge-info">{{ departamentos.length }} departamentos</span>
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Clave</th>
                <th>Nombre</th>
                <th>Descripción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="depto in departamentos" :key="depto.clave" class="row-hover">
                <td><strong class="text-primary">{{ depto.clave }}</strong></td>
                <td>{{ depto.nombre || 'N/A' }}</td>
                <td>{{ depto.descripcion || 'N/A' }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Grid de 3 columnas -->
    <div v-if="movLicencias.length > 0 || movTramites.length > 0 || revisiones.length > 0" class="grid-3-columns">
      <!-- Movimientos de Licencias -->
      <div v-if="movLicencias.length > 0" class="municipal-card">
        <div class="municipal-card-header">
          <h6>
            <font-awesome-icon icon="file-alt" />
            Movimientos de Licencias
            <span class="badge-info">{{ movLicencias.length }}</span>
          </h6>
        </div>
        <div class="municipal-card-body">
          <div class="compact-list">
            <div v-for="mov in movLicencias" :key="mov.id" class="compact-item">
              <strong>{{ mov.tipo }}</strong>
              <small>{{ mov.descripcion }}</small>
            </div>
          </div>
        </div>
      </div>

      <!-- Movimientos de Trámites -->
      <div v-if="movTramites.length > 0" class="municipal-card">
        <div class="municipal-card-header">
          <h6>
            <font-awesome-icon icon="tasks" />
            Movimientos de Trámites
            <span class="badge-info">{{ movTramites.length }}</span>
          </h6>
        </div>
        <div class="municipal-card-body">
          <div class="compact-list">
            <div v-for="mov in movTramites" :key="mov.id" class="compact-item">
              <strong>{{ mov.tipo }}</strong>
              <small>{{ mov.descripcion }}</small>
            </div>
          </div>
        </div>
      </div>

      <!-- Revisiones -->
      <div v-if="revisiones.length > 0" class="municipal-card">
        <div class="municipal-card-header">
          <h6>
            <font-awesome-icon icon="clipboard-check" />
            Revisiones
            <span class="badge-info">{{ revisiones.length }}</span>
          </h6>
        </div>
        <div class="municipal-card-body">
          <div class="compact-list">
            <div v-for="rev in revisiones" :key="rev.id" class="compact-item">
              <strong>{{ rev.tipo }}</strong>
              <small>{{ rev.descripcion }}</small>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Auditoría del Usuario -->
    <div v-if="auditoria.length > 0" class="municipal-card">
      <div class="municipal-card-header">
        <h5>
          <font-awesome-icon icon="history" />
          Auditoría del Usuario
          <span class="badge-info">{{ auditoria.length }} registros</span>
        </h5>
      </div>
      <div class="municipal-card-body">
        <div class="table-responsive">
          <table class="municipal-table">
            <thead class="municipal-table-header">
              <tr>
                <th>Fecha/Hora</th>
                <th>Acción</th>
                <th>Módulo</th>
                <th>Descripción</th>
                <th>IP</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="audit in auditoria" :key="audit.id" class="row-hover">
                <td>
                  <small class="text-muted">
                    <font-awesome-icon icon="calendar" />
                    {{ formatDateTime(audit.fecha_hora) }}
                  </small>
                </td>
                <td>
                  <span class="badge-info">{{ audit.accion || 'N/A' }}</span>
                </td>
                <td>{{ audit.modulo || 'N/A' }}</td>
                <td>{{ audit.descripcion || 'N/A' }}</td>
                <td><code>{{ audit.ip || 'N/A' }}</code></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Estado vacío -->
    <div v-if="!usuarioEncontrado && !loading" class="municipal-card">
      <div class="municipal-card-body text-center">
        <font-awesome-icon icon="search" size="3x" class="empty-icon" />
        <p>Busque un usuario para ver sus privilegios y auditoría</p>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>Cargando información del usuario...</p>
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
      :componentName="'privilegios'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </template>

<script setup>
import { ref } from 'vue'
import DocumentationModal from '@/components/common/DocumentationModal.vue'


import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
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
const searchUsuario = ref('')
const usuarioEncontrado = ref(null)
const permisos = ref([])
const departamentos = ref([])
const movLicencias = ref([])
const movTramites = ref([])
const revisiones = ref([])
const auditoria = ref([])

// Métodos
const buscarPrivilegios = async () => {
  if (!searchUsuario.value) {
    await Swal.fire({
      icon: 'warning',
      title: 'Campo requerido',
      text: 'Por favor ingrese un nombre de usuario',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  setLoading(true, 'Buscando información del usuario...')

  try {
    // Cargar todos los datos en paralelo
    const [
      permisosRes,
      deptosRes,
      movLicRes,
      movTramRes,
      revisionesRes,
      auditoriaRes
    ] = await Promise.all([
      execute(
        'privilegios_privilegios_get_permisos_usuario',
        'padron_licencias',
        [{ nombre: 'p_usuario', valor: searchUsuario.value, tipo: 'string' }],
        'guadalajara'
      ),
      execute(
        'privilegios_privilegios_get_deptos',
        'padron_licencias',
        [{ nombre: 'p_usuario', valor: searchUsuario.value, tipo: 'string' }],
        'guadalajara'
      ),
      execute(
        'privilegios_privilegios_get_mov_licencias',
        'padron_licencias',
        [{ nombre: 'p_usuario', valor: searchUsuario.value, tipo: 'string' }],
        'guadalajara'
      ),
      execute(
        'privilegios_privilegios_get_mov_tramites',
        'padron_licencias',
        [{ nombre: 'p_usuario', valor: searchUsuario.value, tipo: 'string' }],
        'guadalajara'
      ),
      execute(
        'privilegios_privilegios_get_revisiones',
        'padron_licencias',
        [{ nombre: 'p_usuario', valor: searchUsuario.value, tipo: 'string' }],
        'guadalajara'
      ),
      execute(
        'privilegios_privilegios_get_auditoria_usuario',
        'padron_licencias',
        [{ nombre: 'p_usuario', valor: searchUsuario.value, tipo: 'string' }],
        'guadalajara'
      )
    ])

    // Verificar si se encontró el usuario
    if (permisosRes && permisosRes.result && permisosRes.result.length > 0) {
      // Extraer info del usuario del primer permiso
      const firstResult = permisosRes.result[0]
      usuarioEncontrado.value = {
        usuario: searchUsuario.value,
        nombre_completo: firstResult.nombre_completo || '',
        departamento: firstResult.departamento || '',
        nivel: firstResult.nivel || ''
      }

      permisos.value = permisosRes.result || []
      departamentos.value = deptosRes?.result || []
      movLicencias.value = movLicRes?.result || []
      movTramites.value = movTramRes?.result || []
      revisiones.value = revisionesRes?.result || []
      auditoria.value = auditoriaRes?.result || []

      showToast('success', 'Información del usuario cargada correctamente')
    } else {
      usuarioEncontrado.value = null
      permisos.value = []
      departamentos.value = []
      movLicencias.value = []
      movTramites.value = []
      revisiones.value = []
      auditoria.value = []

      await Swal.fire({
        icon: 'warning',
        title: 'Usuario no encontrado',
        text: 'No se encontró información para el usuario especificado',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    handleApiError(error)
    limpiarDatos()
  } finally {
    setLoading(false)
  }
}

const limpiarDatos = () => {
  usuarioEncontrado.value = null
  permisos.value = []
  departamentos.value = []
  movLicencias.value = []
  movTramites.value = []
  revisiones.value = []
  auditoria.value = []
}

const formatDateTime = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}
</script>

<style scoped>
.user-info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 20px;
  padding: 10px;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.info-item label {
  font-size: 12px;
  color: #666;
  font-weight: 600;
  text-transform: uppercase;
}

.info-item strong {
  font-size: 14px;
  color: #333;
}

.grid-3-columns {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 20px;
  margin-bottom: 20px;
}

.municipal-card-header h6 {
  margin: 0;
  font-size: 14px;
  font-weight: 600;
}

.compact-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
  max-height: 300px;
  overflow-y: auto;
}

.compact-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 10px;
  background: #f8f9fa;
  border-radius: 6px;
  border-left: 3px solid #ea8215;
}

.compact-item strong {
  font-size: 13px;
  color: #333;
}

.compact-item small {
  font-size: 11px;
  color: #666;
  line-height: 1.4;
}

.empty-icon {
  color: #ddd;
  margin-bottom: 20px;
}
</style>
