<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="bolt" />
      </div>
      <div class="module-view-info">
        <h1>Alta de Pagos Energía</h1>
        <p>Mercados - Registro de Pagos de Energía Eléctrica</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Filtros de Búsqueda -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="filter" />
            Filtros de Búsqueda
          </h5>
        </div>

        <div class="municipal-card-body">
          <form @submit.prevent="buscarLocales">
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Recaudadora</label>
                <select class="municipal-form-control" v-model="filters.idRecaudadora" @change="onRecChange">
                  <option value="">Todas...</option>
                  <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                    {{ rec.id_rec }} - {{ rec.recaudadora }}
                  </option>
                </select>
              </div>

              <div class="form-group col-md-6">
                <label class="municipal-form-label">Mercado</label>
                <select class="municipal-form-control" v-model="filters.numMercado" :disabled="!filters.idRecaudadora">
                  <option value="">Todos...</option>
                  <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                    {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                  </option>
                </select>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Categoría</label>
                <select class="municipal-form-control" v-model="filters.categoria">
                  <option value="">Todas...</option>
                  <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">
                    {{ cat.categoria }} - {{ cat.descripcion }}
                  </option>
                </select>
              </div>

              <div class="form-group col-md-6">
                <label class="municipal-form-label">Sección</label>
                <select class="municipal-form-control" v-model="filters.seccion">
                  <option value="">Todas...</option>
                  <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                    {{ sec.seccion }} - {{ sec.descripcion }}
                  </option>
                </select>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Local</label>
                <input type="number" class="municipal-form-control" v-model.number="filters.local" placeholder="Todos" />
              </div>

              <div class="form-group col-md-6">
                <label class="municipal-form-label">Letra</label>
                <input type="text" class="municipal-form-control" v-model="filters.letraLocal" placeholder="Todas"
                  maxlength="2" />
              </div>
            </div>

            <div class="row mt-3">
              <div class="col-12">
                <div class="text-end">
                  <button type="button" class="btn-municipal-secondary me-2" @click="limpiarFiltros">
                    <font-awesome-icon icon="eraser" />
                    Limpiar Filtros
                  </button>
                  <button type="submit" class="btn-municipal-primary" :disabled="loading">
                    <font-awesome-icon icon="search" />
                    Buscar Locales
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Tabla de Locales -->
      <div class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="building" />
            Listado de Locales con Energía
          </h5>
          <div class="header-right">
            <span class="badge-purple">{{ totalLocales }} locales</span>
          </div>
        </div>

        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead class="municipal-table-header">
                <tr>
                  <th>ID Local</th>
                  <th>Recaudadora</th>
                  <th>Mercado</th>
                  <th>Categoría</th>
                  <th>Sección</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Nombre</th>
                  <th>Medidor</th>
                  <th>Acción</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="local in paginatedLocales" :key="local.id_local"
                  :class="{ 'table-active': localSeleccionado?.id_local === local.id_local }">
                  <td>{{ local.id_local }}</td>
                  <td>{{ local.oficina }}</td>
                  <td>{{ local.num_mercado }}</td>
                  <td>{{ local.categoria }}</td>
                  <td>{{ local.seccion }}</td>
                  <td><strong>{{ local.local }}</strong></td>
                  <td>{{ local.letra_local || '-' }}</td>
                  <td>{{ local.bloque || '-' }}</td>
                  <td>{{ local.nombre }}</td>
                  <td>{{ local.medidor || 'N/A' }}</td>
                  <td>
                    <button class="btn-municipal-primary btn-sm" @click="seleccionarLocal(local)"
                      :disabled="localSeleccionado?.id_local === local.id_local">
                      <font-awesome-icon
                        :icon="localSeleccionado?.id_local === local.id_local ? 'check-circle' : 'hand-pointer'" />
                      {{ localSeleccionado?.id_local === local.id_local ? 'Seleccionado' : 'Seleccionar' }}
                    </button>
                  </td>
                </tr>
                <tr v-if="!loading && localesDisponibles.length === 0">
                  <td colspan="11" class="text-center text-muted py-4">
                    <font-awesome-icon icon="inbox" size="2x" class="mb-2" />
                    <p>No se encontraron locales. Ajuste los filtros y busque nuevamente.</p>
                  </td>
                </tr>
                <tr v-if="loading">
                  <td colspan="11" class="text-center py-4">
                    <div class="spinner-border text-primary" role="status">
                      <span class="visually-hidden">Cargando...</span>
                    </div>
                    <p class="mt-2 text-muted">Cargando locales...</p>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>

          <!-- Controles de Paginación -->
          <div v-if="localesDisponibles.length > 0" class="pagination-controls">
            <div class="pagination-info">
              <span class="text-muted">
                Mostrando {{ ((currentPage - 1) * itemsPerPage) + 1 }}
                a {{ Math.min(currentPage * itemsPerPage, totalLocales) }}
                de {{ totalLocales }} registros
              </span>
            </div>

            <div class="pagination-size">
              <label class="municipal-form-label me-2">Registros por página:</label>
              <select class="municipal-form-control form-control-sm" :value="itemsPerPage"
                @change="changePageSize($event.target.value)" style="width: auto; display: inline-block;">
                <option value="10">10</option>
                <option value="25">25</option>
                <option value="50">50</option>
                <option value="100">100</option>
              </select>
            </div>

            <div class="pagination-buttons">
              <button class="btn-municipal-secondary btn-sm" @click="goToPage(1)" :disabled="currentPage === 1"
                title="Primera página">
                <font-awesome-icon icon="angle-double-left" />
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage - 1)"
                :disabled="currentPage === 1" title="Página anterior">
                <font-awesome-icon icon="angle-left" />
              </button>

              <button v-for="page in visiblePages" :key="page" class="btn-sm"
                :class="page === currentPage ? 'btn-municipal-primary' : 'btn-municipal-secondary'"
                @click="goToPage(page)">
                {{ page }}
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage(currentPage + 1)"
                :disabled="currentPage === totalPages" title="Página siguiente">
                <font-awesome-icon icon="angle-right" />
              </button>

              <button class="btn-municipal-secondary btn-sm" @click="goToPage(totalPages)"
                :disabled="currentPage === totalPages" title="Última página">
                <font-awesome-icon icon="angle-double-right" />
              </button>
            </div>
          </div>
        </div>
      </div>

    </div>

    <!-- Modal de Registro de Pago de Energía -->
    <div v-if="showModalPago" class="modal-overlay">
      <div class="modal-dialog modal-xl">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <font-awesome-icon icon="bolt" />
              Registro de Pago Energía - Local {{ localSeleccionado?.local }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarModal" aria-label="Cerrar">×</button>
          </div>

          <div class="modal-body">
            <!-- Información del Local -->
            <div class="municipal-card mb-3">
              <div class="municipal-card-header">
                <h6 class="mb-0">
                  <font-awesome-icon icon="info-circle" />
                  Información del Local
                </h6>
              </div>
              <div class="municipal-card-body">
                <div class="row">
                  <div class="col-md-2">
                    <p class="mb-1"><strong>ID Local:</strong> {{ localSeleccionado.id_local }}</p>
                  </div>
                  <div class="col-md-3">
                    <p class="mb-1"><strong>Nombre:</strong> {{ localSeleccionado.nombre }}</p>
                  </div>
                  <div class="col-md-2">
                    <p class="mb-1"><strong>Medidor:</strong> {{ localSeleccionado.medidor || 'N/A' }}</p>
                  </div>
                  <div class="col-md-2">
                    <p class="mb-1"><strong>Superficie:</strong> {{ localSeleccionado.superficie }} m²</p>
                  </div>
                  <div class="col-md-3">
                    <p class="mb-1"><strong>Ubicación:</strong> Cat: {{ localSeleccionado.categoria }}, Sec: {{
                      localSeleccionado.seccion }}, Local: {{ localSeleccionado.local }}</p>
                  </div>
                </div>
              </div>
            </div>

            <!-- Formulario de Pago de Energía -->
            <div class="municipal-card mb-3">
              <div class="municipal-card-header">
                <h6 class="mb-0">
                  <font-awesome-icon icon="edit" />
                  Datos del Pago de Energía
                </h6>
              </div>
              <div class="municipal-card-body">
                <form @submit.prevent="verificarYAgregar">
                  <div class="form-row">
                    <div class="form-group col-md-6">
                      <label class="municipal-form-label">Año <span class="required">*</span></label>
                      <input type="number" class="municipal-form-control" v-model.number="pago.axo" placeholder="2024"
                        :disabled="loading" required />
                    </div>

                    <div class="form-group col-md-6">
                      <label class="municipal-form-label">Bimestre <span class="required">*</span></label>
                      <input type="number" class="municipal-form-control" v-model.number="pago.bimestre"
                        placeholder="1-6" min="1" max="6" :disabled="loading" required />
                    </div>
                  </div>

                  <div class="form-row">
                    <div class="form-group col-md-6">
                      <label class="municipal-form-label">Fecha de Pago <span class="required">*</span></label>
                      <input type="date" class="municipal-form-control" v-model="pago.fechaPago" :disabled="loading"
                        required />
                    </div>

                    <div class="form-group col-md-6">
                      <label class="municipal-form-label">Fecha de Ingreso <span class="required">*</span></label>
                      <input type="date" class="municipal-form-control" v-model="pago.fechaIngreso" :disabled="loading"
                        required />
                    </div>
                  </div>

                  <div class="form-row">
                    <div class="form-group col-md-6">
                      <label class="municipal-form-label">Oficina de Pago <span class="required">*</span></label>
                      <input type="number" class="municipal-form-control" v-model.number="pago.oficinaPago"
                        placeholder="Oficina" :disabled="loading" required />
                    </div>

                    <div class="form-group col-md-6">
                      <label class="municipal-form-label">Caja <span class="required">*</span></label>
                      <input type="text" class="municipal-form-control" v-model="pago.cajaPago" placeholder="Caja"
                        maxlength="2" :disabled="loading" required />
                    </div>
                  </div>

                  <div class="form-row">
                    <div class="form-group col-md-6">
                      <label class="municipal-form-label">Operación <span class="required">*</span></label>
                      <input type="number" class="municipal-form-control" v-model.number="pago.operacionPago"
                        placeholder="Núm. Operación" :disabled="loading" required />
                    </div>

                    <div class="form-group col-md-6">
                      <label class="municipal-form-label">Folio/Partida <span class="required">*</span></label>
                      <input type="text" class="municipal-form-control" v-model="pago.folio" placeholder="Folio"
                        maxlength="20" :disabled="loading" required />
                    </div>
                  </div>

                  <div class="form-row">
                    <div class="form-group col-md-6">
                      <label class="municipal-form-label">Importe Energía <span class="required">*</span></label>
                      <input type="number" class="municipal-form-control" v-model.number="pago.importeEnergia"
                        placeholder="0.00" step="0.01" :disabled="loading" min="0.01" required />
                    </div>

                    <div class="form-group col-md-6">
                      <label class="municipal-form-label">Lectura Actual</label>
                      <input type="number" class="municipal-form-control" v-model.number="pago.lecturaActual"
                        placeholder="0" :disabled="loading" />
                    </div>
                  </div>

                  <div class="row mt-4">
                    <div class="col-12">
                      <div class="text-end">
                        <button type="button" class="btn-municipal-secondary me-2" @click="limpiarFormularioPago"
                          :disabled="loading">
                          <font-awesome-icon icon="eraser" />
                          Limpiar
                        </button>
                        <button type="submit" class="btn-municipal-primary me-2" :disabled="loading || !validarPago()">
                          <font-awesome-icon :icon="loading ? 'spinner' : 'save'" :spin="loading" />
                          {{ loading ? 'Grabando...' : 'Agregar Pago' }}
                        </button>
                        <button type="button" class="btn-municipal-secondary" @click="verificarYModificar"
                          :disabled="loading || !validarPago()">
                          <font-awesome-icon :icon="loading ? 'spinner' : 'edit'" :spin="loading" />
                          Modificar Pago
                        </button>
                      </div>
                    </div>
                  </div>
                </form>
              </div>
            </div>

            <!-- Historial de Pagos de Energía del Local -->
            <div v-if="pagosLocal.length > 0" class="municipal-card">
              <div class="municipal-card-header">
                <h6 class="mb-0">
                  <font-awesome-icon icon="history" />
                  Historial de Pagos de Energía ({{ pagosLocal.length }})
                </h6>
              </div>
              <div class="municipal-card-body">
                <div class="table-responsive" style="max-height: 300px; overflow-y: auto;">
                  <table class="municipal-table table-sm">
                    <thead class="municipal-table-header" style="position: sticky; top: 0; z-index: 10;">
                      <tr>
                        <th>Año</th>
                        <th>Bimestre</th>
                        <th>Fecha Pago</th>
                        <th>Importe</th>
                        <th>Lectura</th>
                        <th>Oficina</th>
                        <th>Caja</th>
                        <th>Operación</th>
                        <th>Folio</th>
                        <th>Usuario</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="(pagoHist, index) in pagosLocal" :key="index">
                        <td>{{ pagoHist.axo }}</td>
                        <td>{{ pagoHist.bimestre }}</td>
                        <td>{{ formatFecha(pagoHist.fecha_pago) }}</td>
                        <td><strong>{{ formatMoneda(pagoHist.importe_energia) }}</strong></td>
                        <td>{{ pagoHist.lectura_actual || '-' }}</td>
                        <td>{{ pagoHist.oficina_pago }}</td>
                        <td>{{ pagoHist.caja_pago }}</td>
                        <td>{{ pagoHist.operacion_pago }}</td>
                        <td>{{ pagoHist.folio }}</td>
                        <td>{{ pagoHist.id_usuario }}</td>
                      </tr>
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
            <div v-else class="alert alert-info">
              <font-awesome-icon icon="info-circle" />
              Este local no tiene pagos de energía registrados aún.
            </div>
          </div>

          <div class="modal-footer">
            <button type="button" class="btn-municipal-secondary" @click="cerrarModal">
              <font-awesome-icon icon="times" />
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useGlobalLoading } from '@/composables/useGlobalLoading';
import { useToast } from '@/composables/useToast';
import axios from 'axios';

const router = useRouter();
const { showLoading, hideLoading } = useGlobalLoading();
const { showToast } = useToast();

// Estados
const loading = ref(false);
const recaudadoras = ref([]);
const mercados = ref([]);
const secciones = ref([]);
const categorias = ref([]);
const localesDisponibles = ref([]);
const localSeleccionado = ref(null);
const pagosLocal = ref([]);
const showModalPago = ref(false);

// Paginación
const currentPage = ref(1);
const itemsPerPage = ref(25);

// Filtros de búsqueda
const filters = ref({
  idRecaudadora: '',
  numMercado: '',
  seccion: '',
  categoria: '',
  local: null,
  letraLocal: '',
  bloque: ''
});

// Datos del pago de energía
const pago = ref({
  axo: new Date().getFullYear(),
  bimestre: Math.ceil((new Date().getMonth() + 1) / 2), // Bimestre actual
  fechaPago: new Date().toISOString().split('T')[0],
  fechaIngreso: new Date().toISOString().split('T')[0],
  oficinaPago: null,
  cajaPago: '',
  operacionPago: null,
  importeEnergia: 0,
  lecturaActual: null,
  folio: ''
});

// Cargar datos iniciales
onMounted(async () => {
  await Promise.all([
    fetchRecaudadoras(),
    fetchSecciones(),
    fetchCategorias()
  ]);
  // Cargar todos los locales inicialmente
  await buscarLocales();
});

// Fetch Recaudadoras
async function fetchRecaudadoras() {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success) {
      recaudadoras.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    showToast('Error al cargar recaudadoras: ' + error.message, 'error');
  }
}

// Cambio de recaudadora
async function onRecChange() {
  mercados.value = [];
  filters.value.numMercado = '';

  if (!filters.value.idRecaudadora) return;

  let p_nivel_usuario = 1;
  try {
    showLoading('Cargando mercados...', 'Por favor espere');
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_catalogo_mercados',
        Base: 'padron_licencias',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_id_rec', tipo: 'int4', valor: filters.value.idRecaudadora },
          { nombre: 'p_nivel_usuario', tipo: 'integer', valor: p_nivel_usuario }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      mercados.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    showToast('Error al cargar mercados: ' + error.message, 'error');
  } finally {
    hideLoading();
  }
}

// Fetch Categorías
async function fetchCategorias() {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_categoria_list',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success) {
      categorias.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    showToast('Error al cargar categorías: ' + error.message, 'error');
  }
}

// Fetch Secciones
async function fetchSecciones() {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_secciones',
        Base: 'padron_licencias',
        Esquema: 'publico',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success) {
      secciones.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    showToast('Error al cargar secciones: ' + error.message, 'error');
  }
}

// Buscar Locales con filtros
async function buscarLocales() {
  loading.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consulta_locales_buscar',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: [
          { Nombre: 'p_oficina', Valor: filters.value.idRecaudadora ? parseInt(filters.value.idRecaudadora) : null },
          { Nombre: 'p_num_mercado', Valor: filters.value.numMercado ? parseInt(filters.value.numMercado) : null },
          { Nombre: 'p_categoria', Valor: filters.value.categoria ? parseInt(filters.value.categoria) : null },
          { Nombre: 'p_seccion', Valor: filters.value.seccion || null },
          { Nombre: 'p_local', Valor: filters.value.local || null },
          { Nombre: 'p_letra_local', Valor: filters.value.letraLocal || null },
          { Nombre: 'p_bloque', Valor: filters.value.bloque || null }
        ]
      }
    });

    if (response.data.eResponse.success) {
      localesDisponibles.value = response.data.eResponse.data.result || [];
      currentPage.value = 1; // Reset a la primera página
      if (localesDisponibles.value.length > 0) {
        showToast(`Se encontraron ${localesDisponibles.value.length} locales con energía`, 'success');
      } else {
        showToast('No se encontraron locales con los filtros especificados', 'info');
      }
    } else {
      showToast(response.data.eResponse.message || 'Error al cargar locales', 'error');
    }
  } catch (error) {
    console.error('Error al cargar locales:', error);
    showToast('Error de conexión al cargar locales', 'error');
  } finally {
    loading.value = false;
  }
}

// Limpiar filtros
function limpiarFiltros() {
  filters.value = {
    idRecaudadora: '',
    numMercado: '',
    seccion: '',
    categoria: '',
    local: null,
    letraLocal: '',
    bloque: ''
  };
  mercados.value = [];
  buscarLocales();
}

// Seleccionar un local de la lista
async function seleccionarLocal(local) {
  localSeleccionado.value = local;
  showToast('Local seleccionado correctamente', 'success');
  // Cargar pagos de energía del local
  await cargarPagosLocal(local.id_local);
  // Abrir modal
  showModalPago.value = true;
}

// Cerrar modal
function cerrarModal() {
  showModalPago.value = false;
  limpiarFormularioPago();
}

// Deseleccionar local
function deseleccionarLocal() {
  localSeleccionado.value = null;
  pagosLocal.value = [];
  limpiarFormularioPago();
  showModalPago.value = false;
}

// Cargar pagos de energía del local
async function cargarPagosLocal(idLocal) {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_energia_listar',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_id_local', tipo: 'int4', valor: idLocal }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      pagosLocal.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar pagos de energía:', error);
  }
}

// Validar datos del pago
function validarPago() {
  return localSeleccionado.value &&
    pago.value.axo > 0 &&
    pago.value.bimestre >= 1 && pago.value.bimestre <= 6 &&
    pago.value.fechaPago &&
    pago.value.fechaIngreso &&
    pago.value.oficinaPago &&
    pago.value.cajaPago &&
    pago.value.operacionPago &&
    pago.value.importeEnergia > 0 &&
    pago.value.folio;
}

// Verificar y agregar pago
async function verificarYAgregar() {
  if (!validarPago()) {
    showToast('Complete todos los campos del pago', 'warning');
    return;
  }

  // Primero verificar si ya existe el pago
  try {
    showLoading('Verificando pago...', 'Por favor espere');
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_energia_consultar_pago',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_id_local', tipo: 'int4', valor: localSeleccionado.value.id_local },
          { nombre: 'p_axo', tipo: 'int4', valor: pago.value.axo },
          { nombre: 'p_bimestre', tipo: 'int4', valor: pago.value.bimestre }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      const result = response.data.eResponse.data.result;
      if (result && result.length > 0) {
        showToast('Ya existe un pago de energía para este local, año y bimestre', 'warning');
        return;
      }
      // Si no existe, agregar el pago
      await agregarPago();
    }
  } catch (error) {
    showToast('Error al verificar pago: ' + error.message, 'error');
  } finally {
    hideLoading();
  }
}

// Agregar pago
async function agregarPago() {
  try {
    showLoading('Agregando pago de energía...', 'Por favor espere');
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_energia_agregar',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_id_local', tipo: 'int4', valor: localSeleccionado.value.id_local },
          { nombre: 'p_axo', tipo: 'int4', valor: pago.value.axo },
          { nombre: 'p_bimestre', tipo: 'int4', valor: pago.value.bimestre },
          { nombre: 'p_fecha_pago', tipo: 'date', valor: pago.value.fechaPago },
          { nombre: 'p_oficina_pago', tipo: 'int4', valor: pago.value.oficinaPago },
          { nombre: 'p_caja_pago', tipo: 'text', valor: pago.value.cajaPago },
          { nombre: 'p_operacion_pago', tipo: 'int4', valor: pago.value.operacionPago },
          { nombre: 'p_importe_energia', tipo: 'numeric', valor: pago.value.importeEnergia },
          { nombre: 'p_lectura_actual', tipo: 'int4', valor: pago.value.lecturaActual },
          { nombre: 'p_folio', tipo: 'text', valor: pago.value.folio },
          { nombre: 'p_id_usuario', tipo: 'int4', valor: 1 },
          { nombre: 'p_fecha_ingreso', tipo: 'date', valor: pago.value.fechaIngreso }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      showToast('Pago de energía agregado correctamente. El historial se ha actualizado.', 'success');
      limpiarFormularioPago();
      // Recargar pagos del local para actualizar el historial
      await cargarPagosLocal(localSeleccionado.value.id_local);
    }
  } catch (error) {
    showToast('Error al agregar pago: ' + error.message, 'error');
  } finally {
    hideLoading();
  }
}

// Verificar y modificar pago
async function verificarYModificar() {
  if (!validarPago()) {
    showToast('Complete todos los campos del pago', 'warning');
    return;
  }

  try {
    showLoading('Modificando pago de energía...', 'Por favor espere');
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_energia_modificar',
        Base: 'padron_licencias',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_id_local', tipo: 'int4', valor: localSeleccionado.value.id_local },
          { nombre: 'p_axo', tipo: 'int4', valor: pago.value.axo },
          { nombre: 'p_bimestre', tipo: 'int4', valor: pago.value.bimestre },
          { nombre: 'p_fecha_pago', tipo: 'date', valor: pago.value.fechaPago },
          { nombre: 'p_oficina_pago', tipo: 'int4', valor: pago.value.oficinaPago },
          { nombre: 'p_caja_pago', tipo: 'text', valor: pago.value.cajaPago },
          { nombre: 'p_operacion_pago', tipo: 'int4', valor: pago.value.operacionPago },
          { nombre: 'p_importe_energia', tipo: 'numeric', valor: pago.value.importeEnergia },
          { nombre: 'p_lectura_actual', tipo: 'int4', valor: pago.value.lecturaActual },
          { nombre: 'p_folio', tipo: 'text', valor: pago.value.folio },
          { nombre: 'p_id_usuario', tipo: 'int4', valor: 1 }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      showToast('Pago de energía modificado correctamente. El historial se ha actualizado.', 'success');
      limpiarFormularioPago();
      // Recargar pagos del local para actualizar el historial
      await cargarPagosLocal(localSeleccionado.value.id_local);
    }
  } catch (error) {
    showToast('Error al modificar pago: ' + error.message, 'error');
  } finally {
    hideLoading();
  }
}

// Limpiar formulario de pago
function limpiarFormularioPago() {
  pago.value = {
    axo: new Date().getFullYear(),
    bimestre: Math.ceil((new Date().getMonth() + 1) / 2),
    fechaPago: new Date().toISOString().split('T')[0],
    fechaIngreso: new Date().toISOString().split('T')[0],
    oficinaPago: null,
    cajaPago: '',
    operacionPago: null,
    importeEnergia: 0,
    lecturaActual: null,
    folio: ''
  };
}

// Formato de moneda
function formatMoneda(valor) {
  if (!valor) return '$0.00';
  return new Intl.NumberFormat('es-MX', {
    style: 'currency',
    currency: 'MXN'
  }).format(valor);
}

// Formato de fecha
function formatFecha(fecha) {
  if (!fecha) return '-';
  return new Date(fecha).toLocaleDateString('es-MX');
}

// Computeds para paginación
const totalLocales = computed(() => localesDisponibles.value.length);

const paginatedLocales = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage.value;
  const end = start + itemsPerPage.value;
  return localesDisponibles.value.slice(start, end);
});

const totalPages = computed(() => {
  return Math.ceil(localesDisponibles.value.length / itemsPerPage.value);
});

const visiblePages = computed(() => {
  const pages = [];
  const maxVisible = 5;
  let startPage = Math.max(1, currentPage.value - Math.floor(maxVisible / 2));
  let endPage = Math.min(totalPages.value, startPage + maxVisible - 1);

  if (endPage - startPage < maxVisible - 1) {
    startPage = Math.max(1, endPage - maxVisible + 1);
  }

  for (let i = startPage; i <= endPage; i++) {
    pages.push(i);
  }

  return pages;
});

// Métodos de paginación
const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page;
  }
};

const changePageSize = (newSize) => {
  itemsPerPage.value = parseInt(newSize);
  currentPage.value = 1;
};

// Mostrar ayuda
function mostrarAyuda() {
  showToast('Ayuda: Filtre los locales con energía, seleccione uno y registre los pagos correspondientes', 'info');
}
</script>

<style scoped>
/* Estilos específicos del módulo */
.form-row {
  margin-left: -0.5rem;
  margin-right: -0.5rem;
  margin-bottom: 1rem;
}

.form-group {
  padding-left: 0.5rem;
  padding-right: 0.5rem;
  margin-bottom: 0;
}

.municipal-form-control {
  width: 100%;
}

.required {
  color: #dc3545;
}

.spinner-border {
  width: 3rem;
  height: 3rem;
}

.badge-green {
  background-color: #28a745;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 0.25rem;
  font-size: 0.875rem;
  font-weight: 600;
}

.badge-purple {
  background-color: #6f42c1;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 0.25rem;
  font-size: 0.875rem;
  font-weight: 600;
}

.header-with-badge {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.table-active {
  background-color: rgba(111, 66, 193, 0.1);
}

/* Estilos del Modal */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 1rem;
}

.modal-dialog {
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
  width: 100%;
  max-width: 900px;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  animation: slideDown 0.3s ease-out;
}

.modal-dialog.modal-xl {
  max-width: 1200px;
}

.modal-content {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}

.modal-header {
  background: linear-gradient(135deg, #ea8215 0%, #d97706 100%);
  color: white;
  padding: 1rem 1.5rem;
  border-radius: 8px 8px 0 0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-title {
  margin: 0;
  font-size: 1.25rem;
  font-weight: 600;
}

.btn-close {
  background: transparent;
  border: none;
  color: white;
  font-size: 1.5rem;
  cursor: pointer;
  opacity: 0.8;
  transition: opacity 0.2s;
}

.btn-close:hover {
  opacity: 1;
}

.modal-body {
  padding: 1.5rem;
  overflow-y: auto;
  flex: 1;
}

.modal-footer {
  padding: 1rem 1.5rem;
  background-color: #f8f9fa;
  border-top: 1px solid #dee2e6;
  border-radius: 0 0 8px 8px;
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
}

@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-50px);
  }

  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Alert personalizado */
.alert {
  padding: 1rem;
  border-radius: 0.5rem;
  margin-bottom: 1rem;
}

.alert-info {
  background-color: #d1ecf1;
  border: 1px solid #bee5eb;
  color: #0c5460;
}

/* Paginación usa estilos del tema municipal-theme.css */
</style>
