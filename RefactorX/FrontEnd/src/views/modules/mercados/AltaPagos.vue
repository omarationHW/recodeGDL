<template>
  <div class="module-view">
    <!-- Header del módulo -->
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="cash-register" />
      </div>
      <div class="module-view-info">
        <h1>Alta de Pagos</h1>
        <p>Mercados - Registro de Pagos de Locales</p>
      </div>
      <div class="button-group ms-auto">
        <button class="btn-municipal-purple" @click="mostrarAyuda">
          <font-awesome-icon icon="question-circle" />
          Ayuda
        </button></div>
    </div>

    <div class="module-view-content">
      <!-- Búsqueda de Local -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="search" />
            Búsqueda de Local
          </h5>
        </div>

        <div class="municipal-card-body">
          <form @submit.prevent="buscarLocal">
            <div class="form-row">
              <div class="form-group col-md-6">
                <label class="municipal-form-label">Recaudadora <span class="required">*</span></label>
                <select class="municipal-form-control" v-model="filters.idRecaudadora" @change="onRecChange"
                  :disabled="loading || localEncontrado">
                  <option value="">Seleccione...</option>
                  <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                    {{ rec.id_rec }} - {{ rec.recaudadora }}
                  </option>
                </select>
              </div>

              <div class="form-group col-md-6">
                <label class="municipal-form-label">Mercado <span class="required">*</span></label>
                <select class="municipal-form-control" v-model="filters.numMercado" @change="onMercadoChange"
                  :disabled="loading || !filters.idRecaudadora || localEncontrado">
                  <option value="">Seleccione...</option>
                  <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                    {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                  </option>
                </select>
              </div>
            </div>

            <div class="form-row">
              <div class="form-group col-md-4">
                <label class="municipal-form-label">Categoría <span class="required">*</span></label>
                <input type="text" class="municipal-form-control" v-model="filters.categoria"
                  :disabled="true" readonly
                  :style="{ backgroundColor: '#f5f5f5', cursor: 'not-allowed' }"
                  placeholder="Automático" />
              </div>

              <div class="form-group col-md-4">
                <label class="municipal-form-label">Sección <span class="required">*</span></label>
                <select class="municipal-form-control" v-model="filters.seccion" :disabled="loading || localEncontrado">
                  <option value="">Seleccione...</option>
                  <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                    {{ sec.seccion }} - {{ sec.descripcion }}
                  </option>
                </select>
              </div>

              <div class="form-group col-md-4">
                <label class="municipal-form-label">Local <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="filters.local" placeholder="0"
                  :disabled="loading || localEncontrado" min="1" />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group col-md-4">
                <label class="municipal-form-label">Letra</label>
                <input type="text" class="municipal-form-control" v-model="filters.letraLocal" placeholder=""
                  maxlength="2" :disabled="loading || localEncontrado" />
              </div>

              <div class="form-group col-md-4">
                <label class="municipal-form-label">Bloque</label>
                <input type="text" class="municipal-form-control" v-model="filters.bloque" placeholder="" maxlength="5"
                  :disabled="loading || localEncontrado" />
              </div>
            </div>

            <div class="row mt-3">
              <div class="col-12">
                <div class="text-end">
                  <button v-if="filters.idRecaudadora && filters.numMercado && !localEncontrado && !localSeleccionado"
                    type="button" class="btn-municipal-secondary me-2" @click="mostrarLocalesDisponibles" :disabled="loading">
                    <font-awesome-icon icon="list" />
                    Ver Locales Disponibles
                  </button>
                  <button v-if="localSeleccionado && !localEncontrado" type="submit" class="btn-municipal-primary" :disabled="loading">
                    <font-awesome-icon icon="search" />
                    Cargar datos del Local
                  </button>
                  <button v-if="localEncontrado" type="button" class="btn-municipal-secondary" @click="limpiarFormulario"
                    :disabled="loading">
                    <font-awesome-icon icon="times" />
                    Nueva Búsqueda
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>

      <!-- Información del Local Encontrado -->
      <div v-if="localEncontrado" class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="info-circle" />
            Información del Local
          </h5>
          <div class="header-right">
            <span class="badge-green">Local encontrado</span>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="row">
            <div class="col-md-3">
              <p><strong>ID Local:</strong> {{ localEncontrado.id_local }}</p>
            </div>
            <div class="col-md-3">
              <p><strong>Superficie:</strong> {{ localEncontrado.superficie }} m²</p>
            </div>
            <div class="col-md-3">
              <p><strong>Clave Cuota:</strong> {{ localEncontrado.clave_cuota }}</p>
            </div>
            <div class="col-md-3">
              <p><strong>Oficina:</strong> {{ localEncontrado.oficina }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Listado de Locales Disponibles -->
      <div v-if="mostrarListaLocales && localesDisponibles.length > 0" class="municipal-card">
        <div class="municipal-card-header header-with-badge">
          <h5>
            <font-awesome-icon icon="list" />
            Locales Disponibles en este Mercado
          </h5>
          <div class="header-right">
            <span class="badge-purple">{{ localesDisponibles.length }} locales</span>
            <button class="btn-sm btn-municipal-secondary ms-2" @click="mostrarListaLocales = false">
              <font-awesome-icon icon="times" />
            </button>
          </div>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
            <table class="municipal-table table-sm">
              <thead class="municipal-table-header" style="position: sticky; top: 0; z-index: 10;">
                <tr>
                  <th>Cat.</th>
                  <th>Sec.</th>
                  <th>Local</th>
                  <th>Letra</th>
                  <th>Bloque</th>
                  <th>Nombre</th>
                  <th>Acción</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(local, index) in localesDisponibles" :key="index">
                  <td>{{ local.categoria }}</td>
                  <td>{{ local.seccion }}</td>
                  <td><strong>{{ local.local }}</strong></td>
                  <td>{{ local.letra_local || '-' }}</td>
                  <td>{{ local.bloque || '-' }}</td>
                  <td>{{ local.nombre }}</td>
                  <td>
                    <button class="btn-municipal-primary btn-sm" @click="seleccionarLocal(local)">
                      <font-awesome-icon icon="check" />
                      Usar
                    </button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Formulario de Datos del Pago -->
      <div v-if="localEncontrado" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="money-bill-wave" />
            Datos del Pago
          </h5>
        </div>

        <div class="municipal-card-body">
          <form @submit.prevent="verificarYAgregar">
            <div class="form-row">
              <div class="form-group col-md-3">
                <label class="municipal-form-label">Año <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="pago.axo" placeholder="2024"
                  :disabled="loading" required />
              </div>

              <div class="form-group col-md-3">
                <label class="municipal-form-label">Mes/Periodo <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="pago.periodo" placeholder="1-12"
                  min="1" max="12" :disabled="loading" required />
              </div>

              <div class="form-group col-md-3">
                <label class="municipal-form-label">Fecha de Pago <span class="required">*</span></label>
                <input type="date" class="municipal-form-control" v-model="pago.fechaPago" :disabled="loading" required />
              </div>

              <div class="form-group col-md-3">
                <label class="municipal-form-label">Fecha de Ingreso <span class="required">*</span></label>
                <input type="date" class="municipal-form-control" v-model="pago.fechaIngreso" :disabled="loading" required />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group col-md-3">
                <label class="municipal-form-label">Oficina de Pago <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="pago.oficinaPago"
                  placeholder="Oficina" :disabled="loading" required />
              </div>

              <div class="form-group col-md-2">
                <label class="municipal-form-label">Caja <span class="required">*</span></label>
                <input type="text" class="municipal-form-control" v-model="pago.cajaPago" placeholder="Caja" maxlength="2"
                  :disabled="loading" required />
              </div>

              <div class="form-group col-md-3">
                <label class="municipal-form-label">Operación <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="pago.operacionPago"
                  placeholder="Núm. Operación" :disabled="loading" required />
              </div>

              <div class="form-group col-md-4">
                <label class="municipal-form-label">Folio/Partida <span class="required">*</span></label>
                <input type="text" class="municipal-form-control" v-model="pago.folio" placeholder="Folio" maxlength="20"
                  :disabled="loading" required />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group col-md-4">
                <label class="municipal-form-label">Importe/Renta <span class="required">*</span></label>
                <input type="number" class="municipal-form-control" v-model.number="pago.importePago" placeholder="0.00"
                  step="0.01" :disabled="loading" min="0.01" required />
              </div>
            </div>

            <div class="row mt-4">
              <div class="col-12">
                <div class="text-end">
                  <button type="button" class="btn-municipal-secondary me-2" @click="limpiarFormulario" :disabled="loading">
                    <font-awesome-icon icon="times" />
                    Cancelar
                  </button>
                  <button type="submit" class="btn-municipal-primary me-2" :disabled="loading || !validarPago()">
                    <font-awesome-icon :icon="loading ? 'spinner' : 'save'" :spin="loading" />
                    {{ loading ? 'Grabando...' : 'Agregar Pago' }}
                  </button>
                  <button type="button" class="btn-municipal-warning" @click="verificarYModificar"
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

      <!-- Card de Adeudos -->
      <div v-if="mostrarAdeudos" class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="list" />
            Adeudos del Local
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="table-responsive">
            <table class="municipal-table">
              <thead>
                <tr>
                  <th>Año</th>
                  <th>Periodo</th>
                  <th>Importe</th>
                  <th>Fecha Alta</th>
                  <th>Usuario</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="(adeudo, index) in adeudos" :key="index">
                  <td>{{ adeudo.axo }}</td>
                  <td>{{ adeudo.periodo }}</td>
                  <td>{{ formatMoneda(adeudo.importe) }}</td>
                  <td>{{ formatFecha(adeudo.fecha_alta) }}</td>
                  <td>{{ adeudo.id_usuario }}</td>
                </tr>
                <tr v-if="adeudos.length === 0">
                  <td colspan="5" class="text-center text-muted">
                    No hay adeudos registrados
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Loading Spinner -->
      <div v-if="loading && !localEncontrado" class="text-center py-5">
        <div class="spinner-border text-primary" role="status">
          <span class="visually-hidden">Cargando...</span>
        </div>
        <p class="mt-3 text-muted">Procesando, por favor espere...</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
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
const localEncontrado = ref(null);
const mostrarAdeudos = ref(false);
const adeudos = ref([]);
const localesDisponibles = ref([]);
const mostrarListaLocales = ref(false);
const localSeleccionado = ref(false);

// Filtros de búsqueda
const filters = ref({
  idRecaudadora: '',
  numMercado: '',
  seccion: '',
  categoria: null,
  local: null,
  letraLocal: '',
  bloque: ''
});

// Datos del pago
const pago = ref({
  axo: new Date().getFullYear(),
  periodo: new Date().getMonth() + 1,
  fechaPago: new Date().toISOString().split('T')[0],
  fechaIngreso: new Date().toISOString().split('T')[0],
  oficinaPago: null,
  cajaPago: '',
  operacionPago: null,
  importePago: 0,
  folio: ''
});

// Cargar datos iniciales
onMounted(async () => {
  await Promise.all([
    fetchRecaudadoras(),
    fetchSecciones()
  ]);
});

// Fetch Recaudadoras
async function fetchRecaudadoras() {
  try {
    showLoading('Cargando recaudadoras...', 'Por favor espere');
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Esquema: 'publico',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success) {
      recaudadoras.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    showToast('Error al cargar recaudadoras: ' + error.message, 'error');
  } finally {
    hideLoading();
  }
}

// Cambio de recaudadora
async function onRecChange() {
  mercados.value = [];
  filters.value.numMercado = '';
  filters.value.categoria = null;
  localSeleccionado.value = false;

  if (!filters.value.idRecaudadora) return;

  let p_nivel_usuario = 1; // Obtener de sesión si es necesario
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

// Cambio de mercado - Auto-llenar categoría
function onMercadoChange() {
  const mercadoSeleccionado = mercados.value.find(m => m.num_mercado_nvo == filters.value.numMercado);
  if (mercadoSeleccionado) {
    filters.value.categoria = mercadoSeleccionado.categoria;
  } else {
    filters.value.categoria = null;
  }
  // Limpiar lista de locales disponibles al cambiar de mercado
  localesDisponibles.value = [];
  mostrarListaLocales.value = false;
  localSeleccionado.value = false;
}

// Mostrar locales disponibles
async function mostrarLocalesDisponibles() {
  if (!filters.value.idRecaudadora || !filters.value.numMercado) {
    showToast('Seleccione oficina y mercado primero', 'warning');
    return;
  }

  loading.value = true;
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consulta_locales_buscar',
        Base: 'padron_licencias',
        Esquema: 'publico',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(filters.value.idRecaudadora) },
          { Nombre: 'p_num_mercado', Valor: parseInt(filters.value.numMercado) },
          { Nombre: 'p_categoria', Valor: null },
          { Nombre: 'p_seccion', Valor: null },
          { Nombre: 'p_local', Valor: null },
          { Nombre: 'p_letra_local', Valor: null },
          { Nombre: 'p_bloque', Valor: null }
        ]
      }
    });

    if (response.data.eResponse.success) {
      localesDisponibles.value = response.data.eResponse.data.result || [];
      if (localesDisponibles.value.length > 0) {
        mostrarListaLocales.value = true;
        showToast(`Se encontraron ${localesDisponibles.value.length} locales`, 'success');
      } else {
        showToast('No se encontraron locales en este mercado', 'info');
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

// Seleccionar un local de la lista
function seleccionarLocal(local) {
  filters.value.categoria = local.categoria;
  filters.value.seccion = local.seccion;
  filters.value.local = local.local;
  filters.value.letraLocal = local.letra_local || '';
  filters.value.bloque = local.bloque || '';
  mostrarListaLocales.value = false;
  localSeleccionado.value = true;
  showToast('Local seleccionado. Haga clic en "Cargar Local" para continuar.', 'info');
}

// Fetch Secciones
async function fetchSecciones() {
  try {
    showLoading('Cargando secciones...', 'Por favor espere');
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
  } finally {
    hideLoading();
  }
}

// Validar búsqueda
function validarBusqueda() {
  return filters.value.idRecaudadora &&
    filters.value.numMercado &&
    filters.value.seccion &&
    filters.value.categoria !== null &&
    filters.value.local !== null;
}

// Buscar Local
async function buscarLocal() {
  if (!validarBusqueda()) {
    showToast('Complete todos los campos obligatorios', 'warning');
    return;
  }

  try {
    showLoading('Buscando local...', 'Por favor espere');
    localEncontrado.value = null;

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_buscar_local',
        Base: 'mercados',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_oficina', tipo: 'int4', valor: filters.value.idRecaudadora },
          { nombre: 'p_num_mercado', tipo: 'int4', valor: filters.value.numMercado },
          { nombre: 'p_categoria', tipo: 'int4', valor: filters.value.categoria },
          { nombre: 'p_seccion', tipo: 'text', valor: filters.value.seccion },
          { nombre: 'p_local', tipo: 'int4', valor: filters.value.local },
          { nombre: 'p_letra_local', tipo: 'text', valor: filters.value.letraLocal || '' },
          { nombre: 'p_bloque', tipo: 'text', valor: filters.value.bloque || '' }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      const result = response.data.eResponse.data.result;
      if (result && result.length > 0) {
        localEncontrado.value = result[0];
        showToast('Local encontrado correctamente', 'success');
        // Cargar adeudos del local
        await cargarAdeudos();
      } else {
        showToast('No se encontró el local o está bloqueado/inactivo', 'warning');
      }
    }
  } catch (error) {
    showToast('Error al buscar local: ' + error.message, 'error');
  } finally {
    hideLoading();
  }
}

// Cargar adeudos del local
async function cargarAdeudos() {
  if (!localEncontrado.value) return;

  try {
    showLoading('Cargando adeudos...', 'Por favor espere');
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_listar_adeudos',
        Base: 'padron_licencias',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_id_local', tipo: 'int4', valor: localEncontrado.value.id_local }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      adeudos.value = response.data.eResponse.data.result || [];
      mostrarAdeudos.value = true;
    }
  } catch (error) {
    console.error('Error al cargar adeudos:', error);
  } finally {
    hideLoading();
  }
}

// Validar datos del pago
function validarPago() {
  return localEncontrado.value &&
    pago.value.axo > 0 &&
    pago.value.periodo >= 1 && pago.value.periodo <= 12 &&
    pago.value.fechaPago &&
    pago.value.fechaIngreso &&
    pago.value.oficinaPago &&
    pago.value.cajaPago &&
    pago.value.operacionPago &&
    pago.value.importePago > 0 &&
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
        Operacion: 'sp_alta_pagos_consultar_pago',
        Base: 'padron_licencias',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_id_local', tipo: 'int4', valor: localEncontrado.value.id_local },
          { nombre: 'p_axo', tipo: 'int4', valor: pago.value.axo },
          { nombre: 'p_periodo', tipo: 'int4', valor: pago.value.periodo }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      const result = response.data.eResponse.data.result;
      if (result && result.length > 0) {
        showToast('Ya existe un pago para este local, año y periodo', 'warning');
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
    showLoading('Agregando pago...', 'Por favor espere');
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_agregar',
        Base: 'padron_licencias',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_id_local', tipo: 'int4', valor: localEncontrado.value.id_local },
          { nombre: 'p_axo', tipo: 'int4', valor: pago.value.axo },
          { nombre: 'p_periodo', tipo: 'int4', valor: pago.value.periodo },
          { nombre: 'p_fecha_pago', tipo: 'date', valor: pago.value.fechaPago },
          { nombre: 'p_oficina_pago', tipo: 'int4', valor: pago.value.oficinaPago },
          { nombre: 'p_caja_pago', tipo: 'text', valor: pago.value.cajaPago },
          { nombre: 'p_operacion_pago', tipo: 'int4', valor: pago.value.operacionPago },
          { nombre: 'p_importe_pago', tipo: 'numeric', valor: pago.value.importePago },
          { nombre: 'p_folio', tipo: 'text', valor: pago.value.folio },
          { nombre: 'p_id_usuario', tipo: 'int4', valor: 1 }, // Obtener de sesión
          { nombre: 'p_fecha_ingreso', tipo: 'date', valor: pago.value.fechaIngreso }
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      showToast('Pago agregado correctamente', 'success');
      limpiarFormulario();
      await cargarAdeudos(); // Recargar adeudos
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
    showLoading('Modificando pago...', 'Por favor espere');
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_modificar',
        Base: 'padron_licencias',
        Esquema: 'publico',
        Parametros: [
          { nombre: 'p_id_local', tipo: 'int4', valor: localEncontrado.value.id_local },
          { nombre: 'p_axo', tipo: 'int4', valor: pago.value.axo },
          { nombre: 'p_periodo', tipo: 'int4', valor: pago.value.periodo },
          { nombre: 'p_fecha_pago', tipo: 'date', valor: pago.value.fechaPago },
          { nombre: 'p_oficina_pago', tipo: 'int4', valor: pago.value.oficinaPago },
          { nombre: 'p_caja_pago', tipo: 'text', valor: pago.value.cajaPago },
          { nombre: 'p_operacion_pago', tipo: 'int4', valor: pago.value.operacionPago },
          { nombre: 'p_importe_pago', tipo: 'numeric', valor: pago.value.importePago },
          { nombre: 'p_folio', tipo: 'text', valor: pago.value.folio },
          { nombre: 'p_id_usuario', tipo: 'int4', valor: 1 } // Obtener de sesión
        ]
      }
    });

    if (response.data?.eResponse?.success) {
      showToast('Pago modificado correctamente', 'success');
      limpiarFormulario();
    }
  } catch (error) {
    showToast('Error al modificar pago: ' + error.message, 'error');
  } finally {
    hideLoading();
  }
}

// Limpiar formulario
function limpiarFormulario() {
  filters.value = {
    idRecaudadora: '',
    numMercado: '',
    seccion: '',
    categoria: null,
    local: null,
    letraLocal: '',
    bloque: ''
  };
  pago.value = {
    axo: new Date().getFullYear(),
    periodo: new Date().getMonth() + 1,
    fechaPago: new Date().toISOString().split('T')[0],
    fechaIngreso: new Date().toISOString().split('T')[0],
    oficinaPago: null,
    cajaPago: '',
    operacionPago: null,
    importePago: 0,
    folio: ''
  };
  localEncontrado.value = null;
  mostrarAdeudos.value = false;
  adeudos.value = [];
  mercados.value = [];
  localesDisponibles.value = [];
  mostrarListaLocales.value = false;
  localSeleccionado.value = false;
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

// Mostrar ayuda
function mostrarAyuda() {
  showToast('Ayuda: Complete los datos del mercado, busque el local y registre el pago correspondiente', 'info');
}</script>

<style scoped>
/* Los estilos están definidos en municipal-theme.css */

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
</style>
