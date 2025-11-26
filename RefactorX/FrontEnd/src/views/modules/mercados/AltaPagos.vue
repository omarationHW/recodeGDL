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
        </button>
        <button class="btn-municipal-danger" @click="cerrar">
          <font-awesome-icon icon="times" />
          Cerrar
        </button>
      </div>
    </div>

    <div class="module-view-content">
      <!-- Card de Datos del Mercado -->
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="building" />
            Datos del Mercado
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group col-md-6">
              <label class="municipal-form-label">Recaudadora *</label>
              <select class="municipal-form-control" v-model="filters.idRecaudadora" @change="onRecChange"
                :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                  {{ rec.id_rec }} - {{ rec.recaudadora }}
                </option>
              </select>
            </div>

            <div class="form-group col-md-6">
              <label class="municipal-form-label">Mercado *</label>
              <select class="municipal-form-control" v-model="filters.numMercado"
                :disabled="!filters.idRecaudadora || loading">
                <option value="">Seleccione...</option>
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                  {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
                </option>
              </select>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-2">
              <label class="municipal-form-label">Sección *</label>
              <select class="municipal-form-control" v-model="filters.seccion" :disabled="loading">
                <option value="">Seleccione...</option>
                <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">
                  {{ sec.seccion }} - {{ sec.descripcion }}
                </option>
              </select>
            </div>

            <div class="form-group col-md-2">
              <label class="municipal-form-label">Categoría *</label>
              <input type="number" class="municipal-form-control" v-model.number="filters.categoria" placeholder="0"
                :disabled="loading" />
            </div>

            <div class="form-group col-md-2">
              <label class="municipal-form-label">Local *</label>
              <input type="number" class="municipal-form-control" v-model.number="filters.local" placeholder="0"
                :disabled="loading" />
            </div>

            <div class="form-group col-md-2">
              <label class="municipal-form-label">Letra</label>
              <input type="text" class="municipal-form-control" v-model="filters.letraLocal" placeholder=""
                maxlength="2" :disabled="loading" />
            </div>

            <div class="form-group col-md-2">
              <label class="municipal-form-label">Bloque</label>
              <input type="text" class="municipal-form-control" v-model="filters.bloque" placeholder="" maxlength="5"
                :disabled="loading" />
            </div>

            <div class="form-group col-md-2 d-flex align-items-end">
              <button class="btn-municipal-primary w-100" @click="buscarLocal"
                :disabled="loading || !validarBusqueda()">
                <font-awesome-icon icon="search" v-if="!loading" />
                <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
                Buscar
              </button>
            </div>
          </div>

          <!-- Información del Local Encontrado -->
          <div v-if="localEncontrado" class="alert alert-success mt-3">
            <h6><font-awesome-icon icon="check-circle" /> Local Encontrado</h6>
            <div class="row">
              <div class="col-md-3">
                <strong>ID Local:</strong> {{ localEncontrado.id_local }}
              </div>
              <div class="col-md-3">
                <strong>Superficie:</strong> {{ localEncontrado.superficie }} m²
              </div>
              <div class="col-md-3">
                <strong>Clave Cuota:</strong> {{ localEncontrado.clave_cuota }}
              </div>
              <div class="col-md-3">
                <strong>Oficina:</strong> {{ localEncontrado.oficina }}
              </div>
            </div>
          </div>

          <div v-if="errorBusqueda" class="alert alert-warning mt-3">
            <font-awesome-icon icon="exclamation-triangle" />
            {{ errorBusqueda }}
          </div>
        </div>
      </div>

      <!-- Card de Datos del Pago -->
      <div class="municipal-card mt-3" v-if="localEncontrado">
        <div class="municipal-card-header">
          <h5>
            <font-awesome-icon icon="money-bill-wave" />
            Datos del Pago
          </h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group col-md-2">
              <label class="municipal-form-label">Año *</label>
              <input type="number" class="municipal-form-control" v-model.number="pago.axo" placeholder="2024"
                :disabled="loading" />
            </div>

            <div class="form-group col-md-2">
              <label class="municipal-form-label">Mes/Periodo *</label>
              <input type="number" class="municipal-form-control" v-model.number="pago.periodo" placeholder="1-12"
                min="1" max="12" :disabled="loading" />
            </div>

            <div class="form-group col-md-3">
              <label class="municipal-form-label">Fecha de Pago *</label>
              <input type="date" class="municipal-form-control" v-model="pago.fechaPago" :disabled="loading" />
            </div>

            <div class="form-group col-md-3">
              <label class="municipal-form-label">Fecha de Ingreso *</label>
              <input type="date" class="municipal-form-control" v-model="pago.fechaIngreso" :disabled="loading" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-3">
              <label class="municipal-form-label">Oficina de Pago *</label>
              <input type="number" class="municipal-form-control" v-model.number="pago.oficinaPago"
                placeholder="Oficina" :disabled="loading" />
            </div>

            <div class="form-group col-md-3">
              <label class="municipal-form-label">Caja *</label>
              <input type="text" class="municipal-form-control" v-model="pago.cajaPago" placeholder="Caja" maxlength="2"
                :disabled="loading" />
            </div>

            <div class="form-group col-md-3">
              <label class="municipal-form-label">Operación *</label>
              <input type="number" class="municipal-form-control" v-model.number="pago.operacionPago"
                placeholder="Núm. Operación" :disabled="loading" />
            </div>

            <div class="form-group col-md-3">
              <label class="municipal-form-label">Folio/Partida *</label>
              <input type="text" class="municipal-form-control" v-model="pago.folio" placeholder="Folio" maxlength="20"
                :disabled="loading" />
            </div>
          </div>

          <div class="form-row">
            <div class="form-group col-md-4">
              <label class="municipal-form-label">Importe/Renta *</label>
              <input type="number" class="municipal-form-control" v-model.number="pago.importePago" placeholder="0.00"
                step="0.01" :disabled="loading" />
            </div>
          </div>

          <div class="d-flex justify-content-end mt-3">
            <button class="btn-municipal-success me-2" @click="verificarYAgregar" :disabled="loading || !validarPago()">
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
              <font-awesome-icon icon="save" v-if="!loading" />
              Agregar Pago
            </button>
            <button class="btn-municipal-warning me-2" @click="verificarYModificar"
              :disabled="loading || !validarPago()">
              <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
              <font-awesome-icon icon="edit" v-if="!loading" />
              Modificar Pago
            </button>
            <button class="btn-municipal-secondary" @click="limpiarFormulario" :disabled="loading">
              <font-awesome-icon icon="eraser" />
              Limpiar
            </button>
          </div>
        </div>
      </div>

      <!-- Card de Adeudos -->
      <div class="municipal-card mt-3" v-if="mostrarAdeudos">
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
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';
import { useToast } from 'vue-toastification';

const router = useRouter();
const toast = useToast();

// Estados
const loading = ref(false);
const recaudadoras = ref([]);
const mercados = ref([]);
const secciones = ref([]);
const localEncontrado = ref(null);
const errorBusqueda = ref('');
const mostrarAdeudos = ref(false);
const adeudos = ref([]);

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
    loading.value = true;
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success) {
      recaudadoras.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    toast.error('Error al cargar recaudadoras: ' + error.message);
  } finally {
    loading.value = false;
  }
}

// Cambio de recaudadora
async function onRecChange() {
  mercados.value = [];
  filters.value.numMercado = '';

  if (!filters.value.idRecaudadora) return;

  let p_nivel_usuario = 1; // Obtener de sesión si es necesario
  try {
    loading.value = true;
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_catalogo_mercados',
        Base: 'padron_licencias',
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
    toast.error('Error al cargar mercados: ' + error.message);
  } finally {
    loading.value = false;
  }
}

// Fetch Secciones
async function fetchSecciones() {
  try {
    loading.value = true;
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_secciones',
        Base: 'padron_licencias',
        Parametros: []
      }
    });

    if (response.data?.eResponse?.success) {
      secciones.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    toast.error('Error al cargar secciones: ' + error.message);
  } finally {
    loading.value = false;
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
    toast.warning('Complete todos los campos obligatorios');
    return;
  }

  try {
    loading.value = true;
    errorBusqueda.value = '';
    localEncontrado.value = null;

    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_buscar_local',
        Base: 'mercados',
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
        toast.success('Local encontrado correctamente');
        // Cargar adeudos del local
        await cargarAdeudos();
      } else {
        errorBusqueda.value = 'No se encontró el local o está bloqueado/inactivo';
        toast.warning(errorBusqueda.value);
      }
    }
  } catch (error) {
    errorBusqueda.value = 'Error al buscar el local';
    toast.error('Error al buscar local: ' + error.message);
  } finally {
    loading.value = false;
  }
}

// Cargar adeudos del local
async function cargarAdeudos() {
  if (!localEncontrado.value) return;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_listar_adeudos',
        Base: 'padron_licencias',
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
    toast.warning('Complete todos los campos del pago');
    return;
  }

  // Primero verificar si ya existe el pago
  try {
    loading.value = true;
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_consultar_pago',
        Base: 'padron_licencias',
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
        toast.warning('Ya existe un pago para este local, año y periodo');
        return;
      }
      // Si no existe, agregar el pago
      await agregarPago();
    }
  } catch (error) {
    toast.error('Error al verificar pago: ' + error.message);
  } finally {
    loading.value = false;
  }
}

// Agregar pago
async function agregarPago() {
  try {
    loading.value = true;
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_agregar',
        Base: 'padron_licencias',
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
      toast.success('Pago agregado correctamente');
      limpiarFormulario();
      await cargarAdeudos(); // Recargar adeudos
    }
  } catch (error) {
    toast.error('Error al agregar pago: ' + error.message);
  } finally {
    loading.value = false;
  }
}

// Verificar y modificar pago
async function verificarYModificar() {
  if (!validarPago()) {
    toast.warning('Complete todos los campos del pago');
    return;
  }

  try {
    loading.value = true;
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_alta_pagos_modificar',
        Base: 'padron_licencias',
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
      toast.success('Pago modificado correctamente');
      limpiarFormulario();
    }
  } catch (error) {
    toast.error('Error al modificar pago: ' + error.message);
  } finally {
    loading.value = false;
  }
}

// Limpiar formulario
function limpiarFormulario() {
  localEncontrado.value = null;
  errorBusqueda.value = '';
  mostrarAdeudos.value = false;
  adeudos.value = [];
  filters.value.categoria = null;
  filters.value.local = null;
  filters.value.letraLocal = '';
  filters.value.bloque = '';
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
  toast.info('Ayuda: Complete los datos del mercado, busque el local y registre el pago correspondiente');
}

// Cerrar
function cerrar() {
  router.push('/');
}
</script>

<style scoped>
.form-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 1rem;
}

.form-group {
  flex: 1;
  min-width: 200px;
  display: flex;
  flex-direction: column;
}

.alert {
  padding: 1rem;
  border-radius: 0.25rem;
  margin-bottom: 1rem;
}

.alert-success {
  background-color: #d4edda;
  border-color: #c3e6cb;
  color: #155724;
}

.alert-warning {
  background-color: #fff3cd;
  border-color: #ffeeba;
  color: #856404;
}
</style>
