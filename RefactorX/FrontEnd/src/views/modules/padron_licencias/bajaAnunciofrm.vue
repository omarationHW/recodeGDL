<template>
  <div class="module-view">
    <!-- Header -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="ban" />
      </div>
      <div class="module-view-info">
        <h1>Baja de Anuncios</h1>
        <p>Padrón de Licencias - Dar de baja anuncios publicitarios</p>
      </div>
      <div class="button-group ms-auto">
        <button
          class="btn-municipal-secondary"
          @click="regresarConsulta"
        >
          <font-awesome-icon icon="arrow-left" />
          Regresar a Consulta
        </button>
        <button
          class="btn-municipal-purple"
          @click="openDocumentation"
        >
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Panel de Búsqueda (Colapsable) -->
      <div class="municipal-card">
        <div
          class="municipal-card-header accordion-header clickable-header"
          @click="showBusqueda = !showBusqueda"
        >
          <h5 class="municipal-card-title">
            <font-awesome-icon icon="search" />
            Buscar Anuncio
          </h5>
          <font-awesome-icon
            :icon="showBusqueda ? 'chevron-up' : 'chevron-down'"
            class="accordion-icon"
          />
        </div>
        <div class="municipal-card-body" v-show="showBusqueda">
          <form @submit.prevent="buscarAnuncio">
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">
                  <font-awesome-icon icon="bullhorn" class="me-1" />
                  Número de Anuncio *
                </label>
                <div class="input-group">
                  <input
                    type="number"
                    class="municipal-form-control"
                    v-model.number="searchAnuncio"
                    placeholder="Ingrese número de anuncio"
                    required
                    min="1"
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
            <font-awesome-icon icon="bullhorn" />
            Anuncio #{{ anuncioData.anuncio }}
            <span
              :class="anuncioData.vigente === 'V' ? 'badge-success' : 'badge-danger'"
              class="badge ms-2"
            >
              {{ anuncioData.vigente === 'V' ? 'VIGENTE' : 'NO VIGENTE' }}
            </span>
          </h5>
        </div>
        <div class="municipal-card-body">
          <!-- Datos del Anuncio -->
          <div class="details-grid">
            <!-- Licencia Ligada -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="link" />
                Licencia Ligada
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Licencia:</td>
                  <td>
                    <strong>#{{ anuncioData.licencia }}</strong>
                  </td>
                </tr>
                <tr>
                  <td class="label">Propietario:</td>
                  <td>{{ anuncioData.propietario_licencia || 'N/A' }}</td>
                </tr>
              </table>
            </div>

            <!-- Información del Anuncio -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="info-circle" />
                Información del Anuncio
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Texto:</td>
                  <td>{{ anuncioData.texto_anuncio || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Giro:</td>
                  <td>{{ anuncioData.descripcion_giro || 'N/A' }}</td>
                </tr>
              </table>
            </div>

            <!-- Dimensiones -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="ruler-combined" />
                Dimensiones
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Medidas:</td>
                  <td>
                    {{ anuncioData.medidas1 || '0' }} x {{ anuncioData.medidas2 || '0' }} m
                    <span class="text-muted" v-if="anuncioData.medidas1 && anuncioData.medidas2">
                      ({{ (anuncioData.medidas1 * anuncioData.medidas2).toFixed(2) }} m²)
                    </span>
                  </td>
                </tr>
                <tr>
                  <td class="label">Caras:</td>
                  <td>{{ anuncioData.num_caras || '0' }}</td>
                </tr>
                <tr>
                  <td class="label">Misma Forma:</td>
                  <td>{{ anuncioData.misma_forma || 'N/A' }}</td>
                </tr>
              </table>
            </div>

            <!-- Ubicación -->
            <div class="detail-section">
              <h6 class="section-title">
                <font-awesome-icon icon="map-marker-alt" />
                Ubicación
              </h6>
              <table class="detail-table">
                <tr>
                  <td class="label">Domicilio:</td>
                  <td>
                    {{ anuncioData.ubicacion || 'N/A' }}
                    {{ anuncioData.numext_ubic ? '#' + anuncioData.numext_ubic : '' }}
                    {{ anuncioData.numint_ubic ? 'Int. ' + anuncioData.numint_ubic : '' }}
                  </td>
                </tr>
                <tr>
                  <td class="label">Colonia:</td>
                  <td>{{ anuncioData.colonia_ubic || 'N/A' }}</td>
                </tr>
                <tr>
                  <td class="label">Fecha Otorgamiento:</td>
                  <td>{{ formatDate(anuncioData.fecha_otorgamiento) }}</td>
                </tr>
                <tr v-if="anuncioData.bloqueado > 0">
                  <td colspan="2">
                    <div class="alert alert-warning mb-0">
                      <font-awesome-icon icon="lock" />
                      <strong>Anuncio Bloqueado</strong>
                    </div>
                  </td>
                </tr>
              </table>
            </div>
          </div>

          <!-- Formulario de Baja -->
          <div class="mt-4" v-if="anuncioData.vigente === 'V'">
            <h6 class="section-title text-danger">
              <font-awesome-icon icon="exclamation-triangle" />
              Registrar Baja de Anuncio
            </h6>

            <form @submit.prevent="confirmarBaja">
              <div class="form-row">
                <div class="form-group col-md-12">
                  <label class="municipal-form-label">
                    <font-awesome-icon icon="comment-alt" class="me-1" />
                    Motivo de la Baja *
                  </label>
                  <textarea
                    class="municipal-form-control"
                    v-model="bajaForm.motivo"
                    rows="3"
                    placeholder="Ingrese el motivo detallado de la baja"
                    required
                    maxlength="500"
                  ></textarea>
                  <small class="form-text text-muted">
                    {{ bajaForm.motivo.length }}/500 caracteres
                  </small>
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
                      <strong>Baja por error</strong> (no requiere año/folio)
                    </label>
                  </div>
                </div>
              </div>

              <div class="form-row" v-if="!bajaForm.bajaError">
                <div class="form-group col-md-6">
                  <label class="municipal-form-label">
                    <font-awesome-icon icon="calendar" class="me-1" />
                    Año *
                  </label>
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
                  <label class="municipal-form-label">
                    <font-awesome-icon icon="hashtag" class="me-1" />
                    Folio *
                  </label>
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

              <div class="alert alert-danger mt-3">
                <font-awesome-icon icon="exclamation-circle" />
                <strong>ADVERTENCIA:</strong> Esta acción NO se puede deshacer.
                El anuncio será dado de baja permanentemente.
              </div>

              <div class="form-row">
                <div class="form-group col-md-12">
                  <button
                    type="submit"
                    class="btn-municipal-danger"
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

          <!-- Anuncio ya dado de baja -->
          <div class="alert alert-warning mt-3" v-else>
            <font-awesome-icon icon="info-circle" />
            <strong>Este anuncio ya está dado de baja</strong>
            <p class="mb-0 mt-2">
              <strong>Fecha de baja:</strong> {{ formatDate(anuncioData.fecha_baja) }}<br>
              <strong>Año:</strong> {{ anuncioData.axo_baja || 'N/A' }}<br>
              <strong>Folio:</strong> {{ anuncioData.folio_baja || 'N/A' }}<br>
              <strong>Motivo:</strong> {{ anuncioData.espubic || 'N/A' }}
            </p>
          </div>
        </div>
      </div>

      <!-- Mensaje cuando no hay anuncio buscado -->
      <div class="municipal-card text-center" v-if="!anuncioData && !primeraBusqueda">
        <div class="municipal-card-body py-5">
          <font-awesome-icon icon="search" size="3x" class="text-muted mb-3" />
          <h5 class="text-muted">Busque un anuncio para dar de baja</h5>
          <p class="text-muted">Ingrese el número de anuncio en el panel de búsqueda.</p>
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
      <div class="toast-content">
        <font-awesome-icon :icon="getToastIcon(toast.type)" class="toast-icon" />
        <span class="toast-message">{{ toast.message }}</span>
      </div>
      <span v-if="toast.duration" class="toast-duration">{{ toast.duration }}</span>
      <button class="toast-close" @click="hideToast">
        <font-awesome-icon icon="times" />
      </button>
    </div>

    <!-- Modal de Ayuda -->
    <DocumentationModal
      :show="showDocumentation"
      :componentName="'bajaAnunciofrm'"
      :moduleName="'padron_licencias'"
      @close="closeDocumentation"
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import { useLicenciasErrorHandler } from '@/composables/useLicenciasErrorHandler'
import DocumentationModal from '@/components/common/DocumentationModal.vue'
import Swal from 'sweetalert2'

const router = useRouter()
const { execute } = useApi()
const {
  loading,
  setLoading,
  toast,
  showToast,
  hideToast,
  getToastIcon,
  handleApiError,
  loadingMessage
} = useLicenciasErrorHandler()

// Estado
const showDocumentation = ref(false)
const showBusqueda = ref(true)
const primeraBusqueda = ref(false)
const searchAnuncio = ref(null)
const anuncioData = ref(null)

const bajaForm = ref({
  motivo: '',
  anio: new Date().getFullYear(),
  folio: null,
  bajaError: false
})

// Métodos
const openDocumentation = () => showDocumentation.value = true
const closeDocumentation = () => showDocumentation.value = false

const regresarConsulta = () => {
  router.push('/padron-licencias/consulta-anuncios')
}

const buscarAnuncio = async () => {
  if (!searchAnuncio.value) {
    showToast('warning', 'Ingrese el número de anuncio')
    return
  }

  setLoading(true, 'Buscando anuncio...')
  primeraBusqueda.value = true
  showBusqueda.value = false

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_baja_anuncio_buscar',
      'padron_licencias',
      [{ nombre: 'p_anuncio', valor: searchAnuncio.value, tipo: 'integer' }],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    if (response && response.result && response.result.length > 0) {
      anuncioData.value = response.result[0]
      toast.value.duration = durationText
      showToast('success', 'Anuncio encontrado')
    } else {
      anuncioData.value = null
      showToast('warning', 'No se encontró el anuncio')
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
    showToast('warning', 'Debe ingresar el motivo de la baja')
    return
  }

  if (!bajaForm.value.bajaError && (!bajaForm.value.anio || !bajaForm.value.folio)) {
    showToast('warning', 'Debe ingresar año y folio para baja normal')
    return
  }

  // Validar que el anuncio no esté bloqueado
  if (anuncioData.value.bloqueado > 0) {
    await Swal.fire({
      icon: 'error',
      title: 'Anuncio Bloqueado',
      text: 'No se puede dar de baja el anuncio porque está bloqueado.',
      confirmButtonColor: '#ea8215'
    })
    return
  }

  // Confirmación
  const result = await Swal.fire({
    icon: 'warning',
    title: '¿Dar de baja anuncio?',
    html: `
      <p>¿Está seguro de dar de baja el anuncio <strong>#${anuncioData.value.anuncio}</strong>?</p>
      <p><strong>Texto:</strong> ${anuncioData.value.texto_anuncio || 'N/A'}</p>
      <p><strong>Motivo:</strong> ${bajaForm.value.motivo}</p>
      <p class="text-danger mt-3"><strong>Esta acción NO se puede deshacer</strong></p>
    `,
    showCancelButton: true,
    confirmButtonColor: '#dc3545',
    cancelButtonColor: '#6c757d',
    confirmButtonText: 'Sí, dar de baja',
    cancelButtonText: 'Cancelar'
  })

  if (!result.isConfirmed) return

  // Solicitar firma
  const firmaResult = await solicitarFirma()
  if (!firmaResult.success) return

  // Ejecutar baja
  await ejecutarBaja()
}

const solicitarFirma = async () => {
  const { value: firma } = await Swal.fire({
    title: 'Firma de Autorización',
    input: 'password',
    inputLabel: 'Ingrese su firma para confirmar la baja:',
    inputPlaceholder: 'Firma',
    showCancelButton: true,
    confirmButtonText: 'Aceptar',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ea8215',
    inputValidator: (value) => {
      if (!value) {
        return 'Debe ingresar su firma'
      }
    }
  })

  if (!firma) {
    return { success: false }
  }

  // Verificar firma
  try {
    const response = await execute(
      'sp_verifica_firma',
      'padron_licencias',
      [
        { nombre: 'p_usuario', valor: localStorage.getItem('usuario') || '', tipo: 'string' },
        { nombre: 'p_firma', valor: firma, tipo: 'string' }
      ],
      'guadalajara'
    )

    if (response && response.result && response.result[0]?.firma_valida) {
      return { success: true }
    } else {
      await Swal.fire({
        icon: 'error',
        title: 'Firma Incorrecta',
        text: 'La firma ingresada no es válida',
        confirmButtonColor: '#ea8215'
      })
      return { success: false }
    }
  } catch (error) {
    handleApiError(error)
    return { success: false }
  }
}

const ejecutarBaja = async () => {
  const usuario = localStorage.getItem('usuario') || 'sistema'

  setLoading(true, 'Procesando baja de anuncio...')

  const startTime = performance.now()

  try {
    const response = await execute(
      'sp_baja_anuncio_procesar',
      'padron_licencias',
      [
        { nombre: 'p_anuncio', valor: searchAnuncio.value, tipo: 'integer' },
        { nombre: 'p_motivo', valor: bajaForm.value.motivo, tipo: 'string' },
        { nombre: 'p_axo_baja', valor: bajaForm.value.bajaError ? null : bajaForm.value.anio, tipo: 'integer' },
        { nombre: 'p_folio_baja', valor: bajaForm.value.bajaError ? null : bajaForm.value.folio, tipo: 'integer' },
        { nombre: 'p_usuario', valor: usuario, tipo: 'string' },
        { nombre: 'p_baja_error', valor: bajaForm.value.bajaError, tipo: 'boolean' },
        { nombre: 'p_baja_tiempo', valor: false, tipo: 'boolean' },
        { nombre: 'p_fecha', valor: new Date().toISOString(), tipo: 'timestamp' }
      ],
      'guadalajara'
    )

    const endTime = performance.now()
    const duration = ((endTime - startTime) / 1000).toFixed(2)
    const durationText = duration < 1
      ? `${((endTime - startTime)).toFixed(0)}ms`
      : `${duration}s`

    setLoading(false)

    if (response && response.result && response.result.length > 0) {
      const resultado = response.result[0]

      if (resultado.status === 'ok') {
        await Swal.fire({
          icon: 'success',
          title: 'Baja Registrada',
          text: resultado.result,
          confirmButtonColor: '#ea8215'
        })

        toast.value.duration = durationText
        showToast('success', 'Baja procesada correctamente')

        // Limpiar y buscar de nuevo para mostrar el estado actualizado
        await buscarAnuncio()
      } else {
        await Swal.fire({
          icon: 'error',
          title: 'Error',
          text: resultado.result,
          confirmButtonColor: '#ea8215'
        })
      }
    }
  } catch (error) {
    setLoading(false)
    handleApiError(error)
  }
}

const cancelar = () => {
  searchAnuncio.value = null
  anuncioData.value = null
  primeraBusqueda.value = false
  showBusqueda.value = true
  bajaForm.value = {
    motivo: '',
    anio: new Date().getFullYear(),
    folio: null,
    bajaError: false
  }
}

const formatDate = (date) => {
  if (!date) return 'N/A'
  const d = new Date(date)
  return d.toLocaleDateString('es-MX', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

// Restaurar estado si viene de otra vista
onMounted(() => {
  const savedSearch = localStorage.getItem('bajaanuncio_search')
  if (savedSearch) {
    searchAnuncio.value = parseInt(savedSearch)
    localStorage.removeItem('bajaanuncio_search')
    buscarAnuncio()
  }
})
</script>
