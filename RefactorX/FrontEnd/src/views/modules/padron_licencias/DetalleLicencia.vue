<template>
  <div class="detalle-licencia-view">
    <!-- Header con acciones -->
    <div class="detalle-header">
      <div class="header-left">
        <button class="btn-back" @click="volverAtras">
          <font-awesome-icon icon="arrow-left" />
          Volver
        </button>
        <div class="header-info">
          <h1>
            <font-awesome-icon icon="id-card" />
            Licencia #{{ licenciaData?.licencia }}
          </h1>
          <span v-if="licenciaData?.vigente === 'V'" class="badge-success">VIGENTE</span>
          <span v-else class="badge-danger">BAJA</span>
        </div>
      </div>
      <div class="header-actions">
        <button class="btn-municipal-primary" @click="editarLicencia">
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
    <div class="detalle-grid" v-if="licenciaData">

      <!-- Card: Información del Propietario -->
      <div class="detalle-card">
        <div class="card-header">
          <font-awesome-icon icon="user" />
          <h3>Información del Propietario</h3>
        </div>
        <div class="card-body">
          <div class="info-row">
            <label>Nombre Completo:</label>
            <span>{{ nombreCompleto }}</span>
          </div>
          <div class="info-row">
            <label>RFC:</label>
            <span>{{ licenciaData.rfc || 'N/A' }}</span>
          </div>
          <div class="info-row">
            <label>CURP:</label>
            <span>{{ licenciaData.curp || 'N/A' }}</span>
          </div>
          <div class="info-row">
            <label>Email:</label>
            <span>{{ licenciaData.email || 'N/A' }}</span>
          </div>
          <div class="info-row">
            <label>Teléfono:</label>
            <span>{{ licenciaData.telefono_prop || 'N/A' }}</span>
          </div>
          <div class="info-row">
            <label>Domicilio:</label>
            <span>{{ domicilioPropietario }}</span>
          </div>
        </div>
      </div>

      <!-- Card: Giro y Actividad -->
      <div class="detalle-card">
        <div class="card-header">
          <font-awesome-icon icon="briefcase" />
          <h3>Giro y Actividad</h3>
        </div>
        <div class="card-body">
          <div class="info-row">
            <label>Código SCIAN:</label>
            <span>{{ licenciaData.cod_giro || 'N/A' }}</span>
          </div>
          <div class="info-row">
            <label>Actividad:</label>
            <span class="text-wrap">{{ licenciaData.actividad || 'N/A' }}</span>
          </div>
          <div class="info-row">
            <label>Tipo de Registro:</label>
            <span>{{ licenciaData.tipo_registro || 'N/A' }}</span>
          </div>
          <div class="info-row">
            <label>Fecha de Otorgamiento:</label>
            <span>{{ formatearFecha(licenciaData.fecha_otorgamiento) }}</span>
          </div>
        </div>
      </div>

      <!-- Card: Ubicación del Negocio -->
      <div class="detalle-card">
        <div class="card-header">
          <font-awesome-icon icon="map-marker-alt" />
          <h3>Ubicación del Negocio</h3>
        </div>
        <div class="card-body">
          <div class="info-row">
            <label>Dirección:</label>
            <span class="text-wrap">{{ direccionNegocio }}</span>
          </div>
          <div class="info-row">
            <label>Colonia:</label>
            <span>{{ licenciaData.colonia_ubic || 'N/A' }}</span>
          </div>
          <div class="info-row">
            <label>Código Postal:</label>
            <span>{{ licenciaData.cp || 'N/A' }}</span>
          </div>
          <div class="info-row">
            <label>Zona / Subzona:</label>
            <span>{{ licenciaData.zona }} / {{ licenciaData.subzona }}</span>
          </div>
          <div class="info-row" v-if="licenciaData.x && licenciaData.y">
            <label>Coordenadas GPS:</label>
            <span>{{ licenciaData.y }}, {{ licenciaData.x }}</span>
          </div>
        </div>
      </div>

      <!-- Card: Datos del Establecimiento -->
      <div class="detalle-card">
        <div class="card-header">
          <font-awesome-icon icon="building" />
          <h3>Datos del Establecimiento</h3>
        </div>
        <div class="card-body">
          <div class="info-row">
            <label>Sup. Construida:</label>
            <span>{{ formatNumber(licenciaData.sup_construida) }} m²</span>
          </div>
          <div class="info-row">
            <label>Sup. Autorizada:</label>
            <span>{{ formatNumber(licenciaData.sup_autorizada) }} m²</span>
          </div>
          <div class="info-row">
            <label>Núm. Cajones:</label>
            <span>{{ licenciaData.num_cajones || 0 }}</span>
          </div>
          <div class="info-row">
            <label>Núm. Empleados:</label>
            <span>{{ licenciaData.num_empleados || 0 }}</span>
          </div>
          <div class="info-row">
            <label>Aforo:</label>
            <span>{{ licenciaData.aforo || 0 }} personas</span>
          </div>
          <div class="info-row">
            <label>Inversión:</label>
            <span>${{ formatCurrency(licenciaData.inversion) }}</span>
          </div>
          <div class="info-row">
            <label>Horario:</label>
            <span>{{ licenciaData.rhorario || 'N/A' }}</span>
          </div>
        </div>
      </div>

      <!-- Card: Saldos y Adeudos -->
      <div class="detalle-card">
        <div class="card-header">
          <font-awesome-icon icon="dollar-sign" />
          <h3>Saldos y Adeudos</h3>
        </div>
        <div class="card-body">
          <div class="info-row" v-if="saldoLicencia">
            <label>Adeudo Total:</label>
            <span class="amount-danger">${{ formatCurrency(saldoLicencia.total) }}</span>
          </div>
          <div class="info-row" v-else>
            <label>Adeudo Total:</label>
            <span class="amount-success">$0.00</span>
          </div>
          <button class="btn-municipal-warning btn-sm" @click="verDetalleAdeudo" v-if="saldoLicencia && saldoLicencia.total > 0">
            <font-awesome-icon icon="file-invoice-dollar" />
            Ver Detalle Completo
          </button>
        </div>
      </div>

      <!-- Card: Estado de la Licencia -->
      <div class="detalle-card">
        <div class="card-header">
          <font-awesome-icon icon="info-circle" />
          <h3>Estado de la Licencia</h3>
        </div>
        <div class="card-body">
          <div class="info-row">
            <label>Estatus:</label>
            <span v-if="licenciaData.vigente === 'V'" class="badge-success">VIGENTE</span>
            <span v-else class="badge-danger">BAJA</span>
          </div>
          <div class="info-row" v-if="licenciaData.vigente !== 'V'">
            <label>Fecha de Baja:</label>
            <span>{{ formatearFecha(licenciaData.fecha_baja) }}</span>
          </div>
          <div class="info-row" v-if="licenciaData.bloqueado > 0">
            <label>Bloqueado:</label>
            <span class="badge-warning">SÍ</span>
          </div>
          <div class="info-row" v-if="licenciaData.espubic">
            <label>Observaciones:</label>
            <span class="text-wrap">{{ licenciaData.espubic }}</span>
          </div>
        </div>
      </div>

    </div>

    <!-- Acciones disponibles -->
    <div class="acciones-rapidas" v-if="licenciaData">
      <h3>Acciones Disponibles</h3>
      <div class="acciones-grid">
        <button class="accion-btn" @click="irAModificar">
          <font-awesome-icon icon="edit" />
          <span>Modificar Licencia</span>
        </button>
        <button class="accion-btn" @click="irABloquear">
          <font-awesome-icon icon="lock" />
          <span>Bloquear/Desbloquear</span>
        </button>
        <button class="accion-btn" @click="irABaja" v-if="licenciaData.vigente === 'V'">
          <font-awesome-icon icon="times-circle" />
          <span>Dar de Baja</span>
        </button>
        <button class="accion-btn" @click="verHistorial">
          <font-awesome-icon icon="history" />
          <span>Ver Historial</span>
        </button>
        <button class="accion-btn" @click="verAnuncios">
          <font-awesome-icon icon="bullhorn" />
          <span>Ver Anuncios</span>
        </button>
        <button class="accion-btn" @click="generarConstancia">
          <font-awesome-icon icon="file-alt" />
          <span>Generar Constancia</span>
        </button>
      </div>
    </div>

    <!-- Si no hay datos -->
    <div v-else class="no-data">
      <font-awesome-icon icon="exclamation-triangle" />
      <p>No se encontraron datos de la licencia</p>
      <button class="btn-municipal-primary" @click="volverAtras">
        Volver a Búsqueda
      </button>
    </div>

  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useApi } from '@/composables/useApi'
import Swal from 'sweetalert2'

const router = useRouter()
const { execute } = useApi()

const licenciaData = ref(null)
const saldoLicencia = ref(null)

// Computed properties
const nombreCompleto = computed(() => {
  if (!licenciaData.value) return 'N/A'
  const nombre = licenciaData.value.propietario || ''
  const primer = licenciaData.value.primer_ap || ''
  const segundo = licenciaData.value.segundo_ap || ''
  return `${nombre} ${primer} ${segundo}`.trim() || 'N/A'
})

const domicilioPropietario = computed(() => {
  if (!licenciaData.value) return 'N/A'
  const dom = licenciaData.value.domicilio || ''
  const ext = licenciaData.value.numext_prop || ''
  const int = licenciaData.value.numint_prop || ''
  const col = licenciaData.value.colonia_prop || ''
  return `${dom} ${ext}${int ? ' Int. ' + int : ''}, ${col}`.trim() || 'N/A'
})

const direccionNegocio = computed(() => {
  if (!licenciaData.value) return 'N/A'
  const calle = licenciaData.value.ubicacion || ''
  const ext = licenciaData.value.numext_ubic || ''
  const letraExt = licenciaData.value.letraext_ubic || ''
  const int = licenciaData.value.numint_ubic || ''
  const letraInt = licenciaData.value.letraint_ubic || ''
  return `${calle} ${ext}${letraExt}${int ? ' Int. ' + int + letraInt : ''}`.trim() || 'N/A'
})

// Métodos
const cargarDatos = async () => {
  // Cargar desde localStorage
  const datosGuardados = localStorage.getItem('licenciaActual')
  if (datosGuardados) {
    licenciaData.value = JSON.parse(datosGuardados)

    // Cargar saldo
    if (licenciaData.value.id_licencia) {
      await cargarSaldo(licenciaData.value.id_licencia)
    }
  }
}

const cargarSaldo = async (idLicencia) => {
  try {
    const response = await execute(
      'SP_GET_SALDO_LICENCIA',
      'padron_licencias',
      [{ nombre: 'p_id_licencia', valor: idLicencia, tipo: 'integer' }],
      'guadalajara',
      null,
      'comun'
    )

    if (response && response.result && response.result.length > 0) {
      saldoLicencia.value = response.result[0]
    }
  } catch (error) {
    console.error('Error cargando saldo:', error)
  }
}

const formatearFecha = (fecha) => {
  if (!fecha) return 'N/A'
  const date = new Date(fecha)
  return date.toLocaleDateString('es-MX', { year: 'numeric', month: 'long', day: 'numeric' })
}

const formatCurrency = (value) => {
  if (!value) return '0.00'
  return parseFloat(value).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ',')
}

const formatNumber = (value) => {
  if (!value) return '0'
  return parseFloat(value).toFixed(2)
}

const volverAtras = () => {
  router.push('/padron-licencias/modificacion-licencias')
}

const editarLicencia = () => {
  router.push('/padron-licencias/modificacion-licencias')
}

const irAModificar = () => {
  router.push('/padron-licencias/modificacion-licencias')
}

const irABloquear = () => {
  router.push('/padron-licencias/bloquear-licencia')
}

const irABaja = () => {
  router.push('/padron-licencias/baja-licencia')
}

const verHistorial = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Historial de Licencia',
    text: 'Funcionalidad de historial en desarrollo',
    confirmButtonColor: '#ea8215'
  })
}

const verAnuncios = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Anuncios Asociados',
    text: 'Funcionalidad de anuncios en desarrollo',
    confirmButtonColor: '#ea8215'
  })
}

const generarConstancia = () => {
  router.push('/padron-licencias/constancias')
}

const verDetalleAdeudo = async () => {
  await Swal.fire({
    icon: 'info',
    title: 'Detalle de Adeudo',
    html: `
      <div style="text-align: left;">
        <p><strong>Adeudo Total:</strong> $${formatCurrency(saldoLicencia.value?.total || 0)}</p>
        <p>El desglose detallado de adeudos estará disponible próximamente.</p>
      </div>
    `,
    confirmButtonColor: '#ea8215'
  })
}

const imprimirDetalle = () => {
  window.print()
}

onMounted(() => {
  cargarDatos()
})
</script>

<style scoped>
.detalle-licencia-view {
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

.amount-danger {
  color: #dc2626;
  font-weight: 700;
  font-size: 1.25rem;
}

.amount-success {
  color: #059669;
  font-weight: 700;
  font-size: 1.25rem;
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
  color: #f59e0b;
  margin-bottom: 1rem;
}

.no-data p {
  font-size: 1.25rem;
  color: #6b7280;
  margin-bottom: 2rem;
}

@media (max-width: 768px) {
  .detalle-licencia-view {
    padding: 1rem;
  }

  .detalle-header {
    flex-direction: column;
    gap: 1rem;
  }

  .header-left {
    flex-direction: column;
    width: 100%;
  }

  .header-actions {
    width: 100%;
    flex-direction: column;
  }

  .detalle-grid {
    grid-template-columns: 1fr;
  }

  .info-row {
    grid-template-columns: 1fr;
    gap: 0.25rem;
  }

  .acciones-grid {
    grid-template-columns: 1fr;
  }
}

@media print {
  .header-actions,
  .btn-back,
  .acciones-rapidas {
    display: none !important;
  }
}
</style>
