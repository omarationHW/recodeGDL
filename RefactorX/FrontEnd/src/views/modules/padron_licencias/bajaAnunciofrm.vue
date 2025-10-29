<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header" style="position: relative;">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Baja de Anuncio</h1>
        <p>Padrón de Licencias - Gestión de baja de anuncios publicitarios</p></div>
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
                    :disabled="loading || !searchAnuncio"
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
                  <td class="label">Número:</td>
                  <td><strong>{{ anuncioData.anuncio }}</strong></td>
                </tr>
                <tr>
                  <td class="label">Licencia:</td>
                  <td><code>{{ anuncioData.licencia }}</code></td>
                </tr>
                <tr>
                  <td class="label">Propietario:</td>
                  <td>{{ anuncioData.propietario }}</td>
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
              </table>
            </div>

            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="calendar-alt" />
                Fechas y Estado
              </h6>
              <table class="detail-table">
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
                  <td class="label">Estado:</td>
                  <td>
                    <span :class="anuncioData.vigente ? 'badge-success' : 'badge-danger'" class="badge">
                      {{ anuncioData.vigente ? 'Vigente' : 'No Vigente' }}
                    </span>
                  </td>
                </tr>
              </table>
            </div>
          </div>

          <!-- Formulario de Baja -->
          <div class="mt-4" v-if="anuncioData.vigente">
            <h6 class="section-title">
              <font-awesome-icon icon="edit" />
              Registrar Baja
            </h6>
            <form @submit.prevent="confirmarBaja">
              <div class="form-row">
                <div class="form-group col-md-12">
                  <label class="municipal-form-label">Motivo de la baja *:</label>
                  <textarea
                    class="municipal-form-control"
                    v-model="bajaForm.motivo"
                    rows="3"
                    placeholder="Ingrese el motivo de la baja"
                    required
                  ></textarea>
                </div>
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <div class="custom-control custom-checkbox">
                    <input
                      type="checkbox"
                      class="custom-control-input"
                      id="bajaError"
                      v-model="bajaForm.bajaError"
                    />
                    <label class="custom-control-label" for="bajaError">
                      Baja por error (no requiere año/folio, recalcula saldo automáticamente)
                    </label>
                  </div>
                </div>
              </div>

              <div class="form-row" v-if="!bajaForm.bajaError">
                <div class="form-group col-md-6">
                  <label class="municipal-form-label">Año *:</label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="bajaForm.anio"
                    placeholder="2025"
                    min="2000"
                    max="2030"
                    :required="!bajaForm.bajaError"
                  />
                </div>
                <div class="form-group col-md-6">
                  <label class="municipal-form-label">Folio *:</label>
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="bajaForm.folio"
                    placeholder="1234"
                    min="1"
                    :required="!bajaForm.bajaError"
                  />
                </div>
              </div>

              <div class="alert alert-info" v-if="bajaForm.bajaError">
                <font-awesome-icon icon="info-circle" />
                <strong>Baja por error:</strong> Al marcar esta opción, el sistema recalculará automáticamente el saldo de la licencia asociada.
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <button
                    type="submit"
                    class="btn-municipal-danger"
                    :disabled="loading"
                  >
                    <font-awesome-icon icon="ban" /> Dar de Baja Anuncio
                  </button>
                  <button
                    type="button"
                    class="btn-municipal-secondary ms-2"
                    @click="cancelar"
                  >
                    <font-awesome-icon icon="times" /> Cancelar
                  </button>
                </div>
              </div>
            </form>
          </div>

          <div class="alert alert-warning" v-else>
            <strong>Este anuncio ya está dado de baja</strong>
            <p class="mb-0">Fecha de baja: {{ formatDate(anuncioData.fecha_baja) }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Loading overlay -->
    <div v-if="loading" class="loading-overlay">
      <div class="loading-spinner">
        <div class="spinner"></div>
        <p>{{ loadingMessage }}</p>
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

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'bajaAnunciofrm'"
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
  loadingMessage,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError
} = useLicenciasErrorHandler()

// Estado
const searchAnuncio = ref('')
const anuncioData = ref(null)

const bajaForm = ref({
  motivo: '',
  anio: new Date().getFullYear(),
  folio: null,
  bajaError: false
})

// Métodos
const buscarAnuncio = async () => {
  if (!searchAnuncio.value) return

  setLoading(true, 'Buscando anuncio...')
  try {
    const response = await execute(
      'SP_BAJA_ANUNCIO_BUSCAR',
      'padron_licencias',
      [
        { nombre: 'p_anuncio', valor: searchAnuncio.value, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      anuncioData.value = response.result[0]
      showToast('success', 'Anuncio encontrado')
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'No encontrado',
        text: 'El anuncio no existe en el sistema',
        confirmButtonColor: '#ea8215'
      })
      anuncioData.value = null
    }
  } catch (error) {
    handleApiError(error)
    anuncioData.value = null
  } finally {
    setLoading(false)
  }
}

const confirmarBaja = async () => {
  // Validaciones
  if (!bajaForm.value.motivo.trim()) {
    await Swal.fire({
      icon: 'warning',
      title: 'Motivo requerido',
      text: 'Debe ingresar el motivo de la baja',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  if (!bajaForm.value.bajaError && (!bajaForm.value.anio || !bajaForm.value.folio)) {
    await Swal.fire({
      icon: 'warning',
      title: 'Datos incompletos',
      text: 'Debe ingresar año y folio para baja normal',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Verificar permisos
  setLoading(true, 'Verificando permisos...')
  try {
    const permisosResponse = await execute(
      'SP_BAJA_ANUNCIO_VERIFICAR_PERMISOS',
      'padron_licencias',
      [
        { nombre: 'p_anuncio', valor: searchAnuncio.value, tipo: 'string' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (!permisosResponse?.result?.[0]?.tiene_permiso) {
      await Swal.fire({
        icon: 'error',
        title: 'Sin permisos',
        text: 'No tiene permisos para dar de baja este anuncio',
        confirmButtonColor: '#ea8215'
      })
      setLoading(false)
      return
    }
  } catch (error) {
    handleApiError(error)
    setLoading(false)
    return
  }
  setLoading(false)

  // Primera confirmación
  const firstConfirm = await Swal.fire({
    icon: 'warning',
    title: '¿Dar de baja anuncio?',
    html: `
      <p>¿Está seguro de dar de baja el anuncio <strong>#${anuncioData.value.anuncio}</strong>?</p>
      <p><strong>Motivo:</strong> ${bajaForm.value.motivo}</p>
      ${bajaForm.value.bajaError ? '<p class="text-info"><strong>Baja por error - Se recalculará el saldo de la licencia</strong></p>' : ''}
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Continuar',
    cancelButtonText: 'Cancelar'
  })

  if (!firstConfirm.isConfirmed) return

  // Segunda confirmación
  const secondConfirm = await Swal.fire({
    icon: 'question',
    title: 'Confirmación final',
    html: `
      <p class="text-danger"><strong>Esta acción NO se puede deshacer</strong></p>
      <p>El anuncio será dado de baja permanentemente</p>
      ${bajaForm.value.bajaError ? '<p class="text-warning">Se ejecutará el recálculo de saldo de la licencia</p>' : ''}
      <p>¿Desea continuar?</p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, dar de baja',
    cancelButtonText: 'Cancelar'
  })

  if (!secondConfirm.isConfirmed) return

  setLoading(true, 'Procesando baja de anuncio...')
  try {
    // Ejecutar baja de anuncio
    const response = await execute(
      'SP_BAJA_ANUNCIO_PROCESAR',
      'padron_licencias',
      [
        { nombre: 'p_anuncio', valor: searchAnuncio.value, tipo: 'string' },
        { nombre: 'p_motivo', valor: bajaForm.value.motivo, tipo: 'string' },
        { nombre: 'p_anio', valor: bajaForm.value.bajaError ? null : bajaForm.value.anio, tipo: 'integer' },
        { nombre: 'p_folio', valor: bajaForm.value.bajaError ? null : bajaForm.value.folio, tipo: 'integer' },
        { nombre: 'p_baja_error', valor: bajaForm.value.bajaError, tipo: 'boolean' },
        { nombre: 'p_usuario', valor: 'sistema', tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.success) {
        // Si es baja por error, recalcular saldo
        if (bajaForm.value.bajaError && anuncioData.value.licencia) {
          setLoading(true, 'Recalculando saldo de licencia...')
          try {
            await execute(
              'SP_RECALCULA_SALDO_LICENCIA',
              'padron_licencias',
              [
                { nombre: 'p_licencia', valor: anuncioData.value.licencia, tipo: 'string' }
              ],
              'guadalajara'
            )
          } catch (recalcError) {
            console.error('Error al recalcular saldo:', recalcError)
          }
        }

        await Swal.fire({
          icon: 'success',
          title: 'Baja registrada',
          html: `
            <p>${resultado.message}</p>
            ${bajaForm.value.bajaError ? '<p class="text-success"><strong>Saldo de licencia recalculado</strong></p>' : ''}
          `,
          confirmButtonColor: '#ea8215',
          timer: 3000
        })

        cancelar()
        showToast('success', 'Baja de anuncio procesada exitosamente')
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: resultado.message,
          confirmButtonColor: '#ea8215'
        })
      }
    }
  } catch (error) {
    handleApiError(error)
  } finally {
    setLoading(false)
  }
}

const cancelar = () => {
  searchAnuncio.value = ''
  anuncioData.value = null
  bajaForm.value = {
    motivo: '',
    anio: new Date().getFullYear(),
    folio: null,
    bajaError: false
  }
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  try {
    const d = new Date(date)
    return d.toLocaleDateString('es-ES', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}
</script>
