<template>
  <div class="detalle-anuncio-view">
    <!-- Header con acciones -->
    <div class="detalle-header">
      <div class="header-left">
        <button class="btn-back" @click="volverAtras">
          <font-awesome-icon icon="arrow-left" />
          Volver
        </button>
        <div class="header-info">
          <h1>
            <font-awesome-icon icon="ad" />
            Anuncio #{{ anuncioData?.anuncio }}
          </h1>
          <span v-if="anuncioData?.vigente === 'S' || anuncioData?.vigente === 'V'" class="badge-success">VIGENTE</span>
          <span v-else-if="anuncioData?.vigente === 'C'" class="badge-warning">CANCELADO</span>
          <span v-else class="badge-danger">NO VIGENTE</span>
        </div>
      </div>
      <div class="header-actions">
        <button class="btn-municipal-primary" @click="editarAnuncio">
          <font-awesome-icon icon="edit" />
          Editar
        </button>
        <button class="btn-municipal-secondary" @click="imprimirDetalle">
          <font-awesome-icon icon="print" />
          Imprimir
        </button>
      </div>
    </div>

    <!-- Grid de información -->
    <div class="detalle-grid" v-if="anuncioData">

      <!-- Card: Información General -->
      <div class="detalle-card">
        <div class="card-header">
          <font-awesome-icon icon="info-circle" />
          <h3>Información General</h3>
        </div>
        <div class="card-body">
          <div class="info-row">
            <label>ID Anuncio:</label>
            <span class="text-primary"><strong>{{ anuncioData.id_anuncio }}</strong></span>
          </div>
          <div class="info-row">
            <label>No. Anuncio:</label>
            <span class="text-primary"><strong>{{ anuncioData.anuncio }}</strong></span>
          </div>
          <div class="info-row">
            <label>ID Licencia:</label>
            <span v-if="anuncioData.id_licencia">
              <a @click="verLicencia" class="link-licencia">
                {{ anuncioData.id_licencia }} (Licencia: {{ anuncioData.licencia }})
              </a>
            </span>
            <span v-else class="text-muted">Sin licencia asociada</span>
          </div>
          <div class="info-row">
            <label>Propietario:</label>
            <span>{{ anuncioData.propietario || 'Sin propietario' }}</span>
          </div>
          <div class="info-row">
            <label>Giro:</label>
            <span>{{ anuncioData.giro_desc || 'Sin giro' }}</span>
          </div>
          <div class="info-row">
            <label>Vigente:</label>
            <span :class="{
              'badge-success': anuncioData.vigente === 'S' || anuncioData.vigente === 'V',
              'badge-danger': anuncioData.vigente === 'N',
              'badge-warning': anuncioData.vigente === 'C'
            }">
              {{ getVigenteDesc(anuncioData.vigente) }}
            </span>
          </div>
          <div class="info-row">
            <label>Bloqueado:</label>
            <span :class="anuncioData.bloqueado ? 'text-danger' : 'text-success'">
              <strong>{{ anuncioData.bloqueado ? 'SÍ' : 'NO' }}</strong>
            </span>
          </div>
        </div>
      </div>

      <!-- Card: Características del Anuncio -->
      <div class="detalle-card">
        <div class="card-header">
          <font-awesome-icon icon="ad" />
          <h3>Características del Anuncio</h3>
        </div>
        <div class="card-body">
          <div class="info-row">
            <label>Texto:</label>
            <span class="text-wrap">{{ anuncioData.texto_anuncio || 'Sin texto' }}</span>
          </div>
          <div class="info-row">
            <label>Área:</label>
            <span><strong>{{ anuncioData.area_anuncio || '0' }} m²</strong></span>
          </div>
          <div class="info-row">
            <label>Medidas:</label>
            <span>{{ anuncioData.medidas1 || '0' }} x {{ anuncioData.medidas2 || '0' }}</span>
          </div>
          <div class="info-row">
            <label>Número de caras:</label>
            <span>{{ anuncioData.num_caras || '0' }}</span>
          </div>
          <div class="info-row">
            <label>Base impuesto:</label>
            <span class="amount-success">${{ formatearMonto(anuncioData.base_impuesto || 0) }}</span>
          </div>
          <div class="info-row">
            <label>Misma forma:</label>
            <span>{{ anuncioData.misma_forma === 'S' ? 'Sí' : 'No' }}</span>
          </div>
          <div class="info-row">
            <label>Asiento:</label>
            <span>{{ anuncioData.asiento || 'N/A' }}</span>
          </div>
        </div>
      </div>

      <!-- Card: Ubicación -->
      <div class="detalle-card detalle-card-full">
        <div class="card-header">
          <font-awesome-icon icon="map-marker-alt" />
          <h3>Ubicación del Anuncio</h3>
        </div>
        <div class="card-body">
          <div class="info-row">
            <label>Ubicación:</label>
            <span>{{ anuncioData.espubic || anuncioData.ubicacion || 'Sin ubicación' }}</span>
          </div>
          <div class="info-row">
            <label>Colonia:</label>
            <span>{{ anuncioData.colonia_ubic || 'N/A' }}</span>
          </div>
          <div class="info-row">
            <label>No. Exterior:</label>
            <span>{{ numeroExterior }}</span>
          </div>
          <div class="info-row">
            <label>No. Interior:</label>
            <span>{{ numeroInterior }}</span>
          </div>
          <div class="info-row">
            <label>Zona / Subzona:</label>
            <span>{{ anuncioData.zona || 'N/A' }} / {{ anuncioData.subzona || 'N/A' }}</span>
          </div>
          <div class="info-row">
            <label>Código Postal:</label>
            <span>{{ anuncioData.cp || 'N/A' }}</span>
          </div>
        </div>
      </div>

      <!-- Card: Fechas y Estado -->
      <div class="detalle-card detalle-card-full">
        <div class="card-header">
          <font-awesome-icon icon="calendar-alt" />
          <h3>Fechas y Estado</h3>
        </div>
        <div class="card-body">
          <div class="info-row">
            <label>Fecha otorgamiento:</label>
            <span>
              <font-awesome-icon icon="calendar-plus" class="text-success" />
              {{ formatearFecha(anuncioData.fecha_otorgamiento) }}
            </span>
          </div>
          <div class="info-row">
            <label>Fecha baja:</label>
            <span>
              <font-awesome-icon icon="calendar-times" class="text-danger" />
              {{ formatearFecha(anuncioData.fecha_baja) }}
            </span>
          </div>
          <div class="info-row">
            <label>Año baja:</label>
            <span>{{ anuncioData.axo_baja || 'N/A' }}</span>
          </div>
          <div class="info-row">
            <label>Folio baja:</label>
            <span>{{ anuncioData.folio_baja || 'N/A' }}</span>
          </div>
        </div>
      </div>

    </div>

    <!-- Acciones Rápidas -->
    <div class="acciones-rapidas" v-if="anuncioData">
      <h3>
        <font-awesome-icon icon="bolt" />
        Acciones Rápidas
      </h3>
      <div class="acciones-grid">
        <button class="accion-btn" @click="editarAnuncio">
          <font-awesome-icon icon="edit" />
          <span>Modificar Anuncio</span>
        </button>
        <button class="accion-btn" @click="bloquearAnuncio">
          <font-awesome-icon icon="lock" />
          <span>Bloquear/Desbloquear</span>
        </button>
        <button class="accion-btn" @click="darDeBaja">
          <font-awesome-icon icon="trash-alt" />
          <span>Dar de Baja</span>
        </button>
        <button class="accion-btn" @click="verHistorial">
          <font-awesome-icon icon="history" />
          <span>Ver Historial</span>
        </button>
        <button class="accion-btn" v-if="anuncioData.id_licencia" @click="verLicencia">
          <font-awesome-icon icon="file-alt" />
          <span>Ver Licencia</span>
        </button>
        <button class="accion-btn" @click="generarConstancia">
          <font-awesome-icon icon="file-pdf" />
          <span>Generar Constancia</span>
        </button>
      </div>
    </div>

    <!-- Estado de No Datos -->
    <div class="no-data" v-else>
      <font-awesome-icon icon="inbox" />
      <h2>No hay datos del anuncio</h2>
      <p>No se encontró información del anuncio seleccionado.</p>
      <button class="btn-municipal-primary" @click="volverAtras">
        <font-awesome-icon icon="arrow-left" />
        Volver a la búsqueda
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import Swal from 'sweetalert2'

const router = useRouter()
const anuncioData = ref(null)

// Computed properties
const numeroExterior = computed(() => {
  if (!anuncioData.value) return 'N/A'
  const num = anuncioData.value.numext_ubic || ''
  const letra = anuncioData.value.letraext_ubic || ''
  return num || letra ? `${num} ${letra}`.trim() : 'N/A'
})

const numeroInterior = computed(() => {
  if (!anuncioData.value) return 'N/A'
  const num = anuncioData.value.numint_ubic || ''
  const letra = anuncioData.value.letraint_ubic || ''
  return num || letra ? `${num} ${letra}`.trim() : 'N/A'
})

// Métodos
const cargarDatos = () => {
  const datosGuardados = localStorage.getItem('anuncioActual')
  if (datosGuardados) {
    try {
      anuncioData.value = JSON.parse(datosGuardados)
    } catch (error) {
      Swal.fire({
        title: 'Error',
        text: 'No se pudieron cargar los datos del anuncio',
        icon: 'error',
        confirmButtonColor: '#ea8215'
      })
    }
  }
}

const volverAtras = () => {
  router.push('/padron-licencias/consulta-anuncios')
}

const editarAnuncio = () => {
  if (anuncioData.value) {
    // Los datos ya están en localStorage, solo navegar
    router.push('/padron-licencias/modlicfrm')
  }
}

const bloquearAnuncio = async () => {
  const result = await Swal.fire({
    title: 'Bloquear/Desbloquear Anuncio',
    text: '¿Deseas bloquear o desbloquear este anuncio?',
    icon: 'question',
    showCancelButton: true,
    confirmButtonText: 'Bloquear',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#ea8215'
  })

  if (result.isConfirmed) {
    router.push('/padron-licencias/bloquear-anuncio')
  }
}

const darDeBaja = async () => {
  const result = await Swal.fire({
    title: '¿Dar de baja anuncio?',
    text: 'Esta acción cancelará el anuncio en el sistema',
    icon: 'warning',
    showCancelButton: true,
    confirmButtonText: 'Sí, dar de baja',
    cancelButtonText: 'Cancelar',
    confirmButtonColor: '#dc2626'
  })

  if (result.isConfirmed) {
    router.push('/padron-licencias/baja-anuncio')
  }
}

const verHistorial = () => {
  Swal.fire({
    title: 'Historial',
    text: 'Funcionalidad en desarrollo',
    icon: 'info',
    confirmButtonColor: '#ea8215'
  })
}

const verLicencia = () => {
  if (anuncioData.value?.id_licencia) {
    router.push({
      path: '/padron-licencias/consulta-licencias',
      query: { id_licencia: anuncioData.value.id_licencia }
    })
  }
}

const generarConstancia = () => {
  Swal.fire({
    title: 'Generar Constancia',
    text: 'Funcionalidad en desarrollo',
    icon: 'info',
    confirmButtonColor: '#ea8215'
  })
}

const imprimirDetalle = () => {
  window.print()
}

// Utilidades
const getVigenteDesc = (vigente) => {
  const desc = {
    'S': 'Vigente',
    'V': 'Vigente',
    'N': 'No Vigente',
    'C': 'Cancelado'
  }
  return desc[vigente] || vigente || 'Desconocido'
}

const formatearFecha = (fecha) => {
  if (!fecha) return 'N/A'
  try {
    const date = new Date(fecha)
    return date.toLocaleDateString('es-MX', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    })
  } catch (error) {
    return 'Fecha inválida'
  }
}

const formatearMonto = (monto) => {
  if (!monto) return '0.00'
  return new Intl.NumberFormat('es-MX', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(monto)
}

onMounted(() => {
  cargarDatos()
})
</script>

<style scoped>
.detalle-anuncio-view {
  max-width: 1400px;
  margin: 0 auto;
  padding: 2rem;
  background: #f9fafb;
  min-height: 100vh;
}

.detalle-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 2rem;
  background: white;
  padding: 1.5rem;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.header-left {
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.btn-back {
  background: #f3f4f6;
  border: none;
  padding: 0.75rem 1.25rem;
  border-radius: 8px;
  cursor: pointer;
  font-weight: 500;
  color: #374151;
  transition: background 0.2s;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.btn-back:hover {
  background: #e5e7eb;
}

.header-info h1 {
  font-size: 1.75rem;
  color: #111827;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.header-actions {
  display: flex;
  gap: 1rem;
}

.detalle-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.detalle-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.detalle-card-full {
  grid-column: 1 / -1;
}

.card-header {
  background: linear-gradient(135deg, #9363CD 0%, #7B47B8 100%);
  color: white;
  padding: 1rem 1.5rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.card-header h3 {
  margin: 0;
  font-size: 1.125rem;
  font-weight: 600;
}

.card-body {
  padding: 1.5rem;
}

.info-row {
  display: grid;
  grid-template-columns: 180px 1fr;
  gap: 1rem;
  padding: 0.75rem 0;
  border-bottom: 1px solid #f3f4f6;
}

.info-row:last-child {
  border-bottom: none;
}

.info-row label {
  font-weight: 600;
  color: #6b7280;
  font-size: 0.875rem;
}

.info-row span {
  color: #111827;
  font-size: 0.875rem;
}

.text-wrap {
  word-break: break-word;
}

.text-primary {
  color: #9363CD;
}

.text-success {
  color: #059669;
}

.text-danger {
  color: #dc2626;
}

.text-muted {
  color: #9ca3af;
}

.link-licencia {
  color: #9363CD;
  cursor: pointer;
  text-decoration: underline;
}

.link-licencia:hover {
  color: #7B47B8;
}

.amount-success {
  color: #059669;
  font-weight: 700;
  font-size: 1.25rem;
}

.badge-success {
  background: #059669;
  color: white;
  padding: 0.375rem 0.75rem;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 600;
}

.badge-danger {
  background: #dc2626;
  color: white;
  padding: 0.375rem 0.75rem;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 600;
}

.badge-warning {
  background: #f59e0b;
  color: white;
  padding: 0.375rem 0.75rem;
  border-radius: 6px;
  font-size: 0.875rem;
  font-weight: 600;
}

.acciones-rapidas {
  background: white;
  border-radius: 12px;
  padding: 1.5rem;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.acciones-rapidas h3 {
  margin: 0 0 1.5rem 0;
  color: #111827;
  font-size: 1.25rem;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.acciones-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.accion-btn {
  background: #f9fafb;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  padding: 1.25rem;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
  text-align: center;
}

.accion-btn:hover {
  background: #9363CD;
  border-color: #9363CD;
  color: white;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(147, 99, 205, 0.3);
}

.accion-btn svg {
  font-size: 1.5rem;
}

.accion-btn span {
  font-weight: 500;
  font-size: 0.875rem;
}

.no-data {
  background: white;
  border-radius: 12px;
  padding: 4rem 2rem;
  text-align: center;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.no-data svg {
  font-size: 4rem;
  color: #d1d5db;
  margin-bottom: 1.5rem;
}

.no-data h2 {
  color: #6b7280;
  margin-bottom: 0.5rem;
}

.no-data p {
  color: #9ca3af;
  margin-bottom: 2rem;
}

/* Print styles */
@media print {
  .detalle-header .btn-back,
  .header-actions,
  .acciones-rapidas {
    display: none !important;
  }

  .detalle-anuncio-view {
    padding: 0;
    background: white;
  }

  .detalle-card,
  .detalle-header {
    box-shadow: none !important;
    page-break-inside: avoid;
  }
}

/* Responsive */
@media (max-width: 768px) {
  .detalle-anuncio-view {
    padding: 1rem;
  }

  .detalle-header {
    flex-direction: column;
    gap: 1rem;
  }

  .header-left {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
    width: 100%;
  }

  .header-actions {
    width: 100%;
    justify-content: stretch;
  }

  .header-actions button {
    flex: 1;
  }

  .detalle-grid {
    grid-template-columns: 1fr;
  }

  .info-row {
    grid-template-columns: 1fr;
    gap: 0.25rem;
  }

  .acciones-grid {
    grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  }
}
</style>
