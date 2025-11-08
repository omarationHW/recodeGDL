<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="sign" />
      </div>
      <div class="module-view-info">
        <h1>Bloquear/Desbloquear Anuncio</h1>
        <p>Padrón de Licencias - Gestión de bloqueos de anuncios publicitarios</p>
      </div>
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
      <!-- Búsqueda de Anuncio -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="search" />
            Buscar Anuncio
          </h5>
        </div>
        <div class="municipal-card-body">
          <form @submit.prevent="buscarAnuncio">
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Número de Anuncio:</label>
                <div class="input-group">
                  <input
                    type="text"
                    class="municipal-form-control"
                    v-model="searchAnuncio"
                    placeholder="Ingrese número de anuncio"
                    required
                  />
                  <button
                    type="submit"
                    class="btn-municipal-primary"
                    :disabled="!searchAnuncio"
                  >
                    <font-awesome-icon icon="search" /> Buscar
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Información del Anuncio -->
      <div class="municipal-card" v-if="anuncioData">
        <div class="municipal-card-header">
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="sign" />
            Información del Anuncio #{{ anuncioData.anuncio }}
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="details-grid">
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="info-circle" />
                Datos del Anuncio
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Número Anuncio:</td>
                  <td><strong>{{ anuncioData.anuncio }}</strong></td>
                </tr>
                <tr>
                  <td class="label">Licencia:</td>
                  <td><code>{{ anuncioData.licencia }}</code></td>
                </tr>
                <tr>
                  <td class="label">Tipo:</td>
                  <td>{{ anuncioData.tipo_anuncio }}</td>
                </tr>
                <tr>
                  <td class="label">Dimensiones:</td>
                  <td>{{ anuncioData.dimensiones }} m²</td>
                </tr>
                <tr>
                  <td class="label">Ubicación:</td>
                  <td>{{ anuncioData.ubicacion }}</td>
                </tr>
                <tr>
                  <td class="label">Estado:</td>
                  <td>
                    <span :class="anuncioData.vigente ? 'badge-success' : 'badge-danger'" class="badge">
                      <font-awesome-icon :icon="anuncioData.vigente ? 'check-circle' : 'times-circle'" />
                      {{ anuncioData.vigente ? 'Vigente' : 'No Vigente' }}
                    </span>
                  </td>
                </tr>
              </table>
            </div>

            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="user" />
                Información Adicional
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Propietario:</td>
                  <td>{{ anuncioData.propietario || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Fecha Alta:</td>
                  <td>{{ formatDate(anuncioData.fecha_alta) }}</td>
                </tr>
                <tr>
                  <td class="label">Fecha Vencimiento:</td>
                  <td>{{ formatDate(anuncioData.fecha_vencimiento) }}</td>
                </tr>
                <tr>
                  <td class="label">Descripción:</td>
                  <td>{{ anuncioData.descripcion || 'Sin descripción' }}</td>
                </tr>
                <tr>
                  <td class="label">Observaciones:</td>
                  <td>{{ anuncioData.observaciones || 'Sin observaciones' }}</td>
                </tr>
              </table>
            </div>
          </div>

          <!-- Formulario de Bloqueo -->
          <div class="mt-4" v-if="!hasBloqueosActivos">
            <h6 class="section-title">
              <font-awesome-icon icon="lock" />
              Registrar Bloqueo
            </h6>
            <form @submit.prevent="confirmarBloqueo">
              <div class="form-row">
                <div class="form-group col-md-6">
                  <label class="municipal-form-label">Tipo de Bloqueo *:</label>
                  <select
                    class="municipal-form-control"
                    v-model="bloqueoForm.tipo"
                    required
                  >
                    <option value="">Seleccione un tipo...</option>
                    <option value="ADMINISTRATIVO">Administrativo</option>
                    <option value="JURIDICO">Jurídico</option>
                    <option value="FISCAL">Fiscal</option>
                    <option value="TECNICO">Técnico</option>
                    <option value="URBANO">Urbano</option>
                  </select>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <label class="municipal-form-label">Motivo del bloqueo *:</label>
                  <textarea
                    class="municipal-form-control"
                    v-model="bloqueoForm.motivo"
                    rows="3"
                    maxlength="500"
                    placeholder="Ingrese el motivo del bloqueo"
                    required
                  ></textarea>
                  <small class="form-text text-muted">
                    {{ bloqueoForm.motivo.length }}/500 caracteres
                  </small>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <button
                    type="submit"
                    class="btn-municipal-danger"
                  >
                    <font-awesome-icon icon="lock" /> Bloquear Anuncio
                  </button>
                  <button
                    type="button"
                    class="btn-municipal-secondary ms-2"
                    @click="limpiarFormulario"
                  >
                    <font-awesome-icon icon="times" /> Cancelar
                  </button>
                </div>
              </div>
            </form>
          </div>

          <!-- Lista de Bloqueos -->
          <div class="mt-4" v-if="bloqueos.length > 0">
            <h6 class="section-title header-with-badge">
              <span>
                <font-awesome-icon icon="list" />
                Historial de Bloqueos
              </span>
              <span class="badge badge-purple">{{ bloqueos.length }}</span>
            </h6>
            <div class="table-responsive">
              <table class="municipal-table">
                <thead class="municipal-table-header">
                  <tr>
                    <th>Tipo</th>
                    <th>Motivo Bloqueo</th>
                    <th>Fecha Bloqueo</th>
                    <th>Usuario</th>
                    <th>Motivo Desbloqueo</th>
                    <th>Fecha Desbloqueo</th>
                    <th>Estado</th>
                    <th>Acciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="bloqueo in bloqueos" :key="bloqueo.id_bloqueo" class="row-hover">
                    <td>
                      <span class="badge-warning">
                        {{ bloqueo.tipo }}
                      </span>
                    </td>
                    <td>{{ bloqueo.motivo_bloqueo }}</td>
                    <td>
                      <small class="text-muted">
                        <font-awesome-icon icon="calendar" />
                        {{ formatDate(bloqueo.fecha_bloqueo) }}
                      </small>
                    </td>
                    <td><code>{{ bloqueo.usuario_bloqueo }}</code></td>
                    <td>{{ bloqueo.motivo_desbloqueo || '-' }}</td>
                    <td>
                      <small class="text-muted">
                        {{ formatDate(bloqueo.fecha_desbloqueo) }}
                      </small>
                    </td>
                    <td>
                      <span :class="bloqueo.activo ? 'badge-danger' : 'badge-success'" class="badge">
                        <font-awesome-icon :icon="bloqueo.activo ? 'lock' : 'unlock'" />
                        {{ bloqueo.activo ? 'Bloqueado' : 'Desbloqueado' }}
                      </span>
                    </td>
                    <td>
                      <button
                        v-if="bloqueo.activo"
                        class="btn-municipal-success btn-sm"
                        @click="confirmarDesbloqueo(bloqueo)"
                        title="Desbloquear"
                      >
                        <font-awesome-icon icon="unlock" /> Desbloquear
                      </button>
                      <span v-else class="text-muted">-</span>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'BloquearAnunciorm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import { ref, computed } from 'vue'
import { useApi } from '@/composables/useApi'
import { useGlobalLoading } from '@/composables/useGlobalLoading'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import Swal from 'sweetalert2'

// Composables
const showDocumentation = ref(false)
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const { execute } = useApi()
const { showLoading, hideLoading } = useGlobalLoading()
const { handleApiError, showToast } = useLicenciasErrorHandler()

// Estado
const searchAnuncio = ref('')
const anuncioData = ref(null)
const bloqueos = ref([])

const bloqueoForm = ref({
  tipo: '',
  motivo: ''
})

// Computed
const hasBloqueosActivos = computed(() => {
  return bloqueos.value.some(b => b.activo)
})

// Métodos
const buscarAnuncio = async () => {
  if (!searchAnuncio.value) return

  const startTime = Date.now()
  showLoading('Buscando anuncio...')

  try {
    const response = await execute(
      'sp_bloquearanuncio_get_anuncio',
      'licencias',
      [
        { nombre: 'p_anuncio', valor: searchAnuncio.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    hideLoading()
    const duration = ((Date.now() - startTime) / 1000).toFixed(2)

    if (response && response.result && response.result.length > 0) {
      anuncioData.value = response.result[0]
      await cargarBloqueos()
      showToast('success', `Anuncio encontrado (${duration}s)`, 3000, 'bottom-right')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'El anuncio no existe en el sistema',
        confirmButtonColor: '#ea8215'
      })
      anuncioData.value = null
      bloqueos.value = []
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
    anuncioData.value = null
    bloqueos.value = []
  }
}

const cargarBloqueos = async () => {
  try {
    const response = await execute(
      'sp_bloquearanuncio_get_bloqueos',
      'licencias',
      [
        { nombre: 'p_anuncio', valor: searchAnuncio.value, tipo: 'integer' }
      ],
      'guadalajara'
    )

    if (response && response.result) {
      bloqueos.value = response.result
    }
  } catch (error) {
    console.error('Error al cargar bloqueos:', error)
    bloqueos.value = []
  }
}

const confirmarBloqueo = async () => {
  if (!bloqueoForm.value.tipo || !bloqueoForm.value.motivo.trim()) {
    await Swal.fire({
      icon: 'warning',
      title: 'Datos incompletos',
      text: 'Debe completar todos los campos obligatorios',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación
  const confirm = await Swal.fire({
    icon: 'warning',
    title: '¿Bloquear anuncio?',
    html: `
      <p>¿Está seguro de bloquear el anuncio <strong>#${anuncioData.value.anuncio}</strong>?</p>
      <p><strong>Tipo:</strong> ${bloqueoForm.value.tipo}</p>
      <p><strong>Motivo:</strong> ${bloqueoForm.value.motivo}</p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, bloquear',
    cancelButtonText: 'Cancelar'
  })

  if (!confirm.isConfirmed) return

  showLoading('Bloqueando anuncio...')
  try {
    const response = await execute(
      'sp_bloquearanuncio_bloquear',
      'licencias',
      [
        { nombre: 'p_anuncio', valor: searchAnuncio.value, tipo: 'integer' },
        { nombre: 'p_tipo', valor: bloqueoForm.value.tipo, tipo: 'string' },
        { nombre: 'p_motivo', valor: bloqueoForm.value.motivo, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: 'Anuncio bloqueado',
        text: 'El bloqueo se ha registrado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      bloqueoForm.value = { tipo: '', motivo: '' }
      await cargarBloqueos()
      showToast('success', 'Anuncio bloqueado exitosamente', 3000, 'bottom-right')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response?.result?.[0]?.message || 'No se pudo bloquear el anuncio',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const confirmarDesbloqueo = async (bloqueo) => {
  const { value: motivo } = await Swal.fire({
    title: 'Desbloquear anuncio',
    html: `
      <p>Ingrese el motivo del desbloqueo:</p>
      <p><strong>Bloqueo:</strong> ${bloqueo.tipo} - ${bloqueo.motivo_bloqueo}</p>
    `,
    input: 'textarea',
    inputPlaceholder: 'Motivo del desbloqueo...',
    inputAttributes: {
      'aria-label': 'Motivo del desbloqueo',
      rows: 3
    },
    showCancelButton: true,
    confirmButtonColor: '#28a745',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Desbloquear',
    cancelButtonText: 'Cancelar',
    inputValidator: (value) => {
      if (!value) {
        return 'Debe ingresar el motivo del desbloqueo'
      }
    }
  })

  if (!motivo) return

  showLoading('Desbloqueando anuncio...')
  try {
    const response = await execute(
      'sp_bloquearanuncio_desbloquear',
      'licencias',
      [
        { nombre: 'p_id_bloqueo', valor: bloqueo.id_bloqueo, tipo: 'integer' },
        { nombre: 'p_motivo_desbloqueo', valor: motivo, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    hideLoading()

    if (response && response.result && response.result[0]?.success) {
      await Swal.fire({
        icon: 'success',
        title: 'Anuncio desbloqueado',
        text: 'El desbloqueo se ha registrado exitosamente',
        confirmButtonColor: '#ea8215',
        timer: 2000
      })

      await cargarBloqueos()
      showToast('success', 'Anuncio desbloqueado exitosamente', 3000, 'bottom-right')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Error',
        text: response?.result?.[0]?.message || 'No se pudo desbloquear el anuncio',
        confirmButtonColor: '#ea8215'
      })
    }
  } catch (error) {
    hideLoading()
    handleApiError(error)
  }
}

const limpiarFormulario = () => {
  searchAnuncio.value = ''
  anuncioData.value = null
  bloqueos.value = []
  bloqueoForm.value = { tipo: '', motivo: '' }
}

const formatDate = (dateString) => {
  if (!dateString) return 'N/A'
  try {
    const date = new Date(dateString)
    return date.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}
</script>
