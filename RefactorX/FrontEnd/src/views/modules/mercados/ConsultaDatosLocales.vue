<template>
  <div class="container-fluid py-4">
    <div class="municipal-card" style="min-height: 450px;">
      <div class="municipal-card-header">
        <h5 class="mb-0">Consulta de Datos Generales de Locales</h5>
      </div>
      <div class="municipal-card-body">
        <!-- Tipo de búsqueda -->
        <div class="mb-3">
          <div class="form-check form-check-inline">
            <input v-model="opcion" type="radio" class="form-check-input" value="L" id="opLocal">
            <label class="form-check-label" for="opLocal">Por Local</label>
          </div>
          <div class="form-check form-check-inline">
            <input v-model="opcion" type="radio" class="form-check-input" value="N" id="opNombre">
            <label class="form-check-label" for="opNombre">Por Nombre</label>
          </div>
        </div>

        <!-- Búsqueda por Local -->
        <div v-if="opcion === 'L'" class="row g-2 mb-3">
          <div class="col-md-2">
            <label class="form-label">Recaudadora</label>
            <select v-model="form.oficina" class="form-select form-select-sm" @change="onOficinaChange">
              <option value="">Seleccione</option>
              <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
                {{ rec.id_rec }}
              </option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label">Mercado</label>
            <select v-model="form.num_mercado" class="form-select form-select-sm">
              <option value="">Todos</option>
              <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
                {{ merc.num_mercado_nvo }} - {{ merc.descripcion }}
              </option>
            </select>
          </div>
          <div class="col-md-1">
            <label class="form-label">Cat</label>
            <input v-model="form.categoria" type="number" class="form-control form-control-sm" />
          </div>
          <div class="col-md-1">
            <label class="form-label">Sección</label>
            <input v-model="form.seccion" type="text" class="form-control form-control-sm" maxlength="2" />
          </div>
          <div class="col-md-1">
            <label class="form-label">Local</label>
            <input v-model="form.local" type="number" class="form-control form-control-sm" />
          </div>
          <div class="col-md-1">
            <label class="form-label">Letra</label>
            <input v-model="form.letra_local" type="text" class="form-control form-control-sm" maxlength="3" />
          </div>
          <div class="col-md-1">
            <label class="form-label">Bloque</label>
            <input v-model="form.bloque" type="text" class="form-control form-control-sm" maxlength="2" />
          </div>
        </div>

        <!-- Búsqueda por Nombre -->
        <div v-if="opcion === 'N'" class="row g-2 mb-3">
          <div class="col-md-6">
            <label class="form-label">Nombre</label>
            <input v-model="form.nombre" type="text" class="form-control" placeholder="Nombre del local o contribuyente" />
          </div>
        </div>

        <!-- Botones -->
        <div class="mb-4">
          <button class="btn btn-municipal-primary btn-sm me-2" @click="buscar" :disabled="loading">
            <span v-if="loading" class="spinner-border spinner-border-sm me-1"></span>
            Buscar
          </button>
          <button class="btn btn-outline-secondary btn-sm" @click="limpiar">Limpiar</button>
        </div>

        <!-- Resultados -->
        <div v-if="resultados.length" class="table-responsive">
          <table class="table table-sm table-striped table-hover municipal-table">
            <thead>
              <tr>
                <th>Control</th>
                <th>Rec</th>
                <th>Merc</th>
                <th>Cat</th>
                <th>Sección</th>
                <th>Local</th>
                <th>Letra</th>
                <th>Blq</th>
                <th>Nombre</th>
                <th>Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in resultados" :key="row.id_local">
                <td>{{ row.id_local }}</td>
                <td>{{ row.oficina }}</td>
                <td>{{ row.num_mercado }}</td>
                <td>{{ row.categoria }}</td>
                <td>{{ row.seccion }}</td>
                <td>{{ row.local }}</td>
                <td>{{ row.letra_local || '-' }}</td>
                <td>{{ row.bloque || '-' }}</td>
                <td>{{ row.nombre }}</td>
                <td>
                  <button class="btn btn-sm btn-outline-primary" @click="verIndividual(row.id_local)">Ver</button>
                </td>
              </tr>
            </tbody>
          </table>
          <small class="text-muted">Total: {{ resultados.length }} registros</small>
        </div>

        <!-- Detalle Individual -->
        <div v-if="individual" class="mt-4">
          <div class="municipal-card">
            <div class="municipal-card-header d-flex justify-content-between">
              <h6 class="mb-0">Datos Individuales del Local</h6>
              <button class="btn btn-sm btn-outline-secondary" @click="individual = null">Cerrar</button>
            </div>
            <div class="municipal-card-body">
              <div class="row">
                <div class="col-md-6">
                  <table class="table table-sm table-bordered">
                    <tr><th width="40%">ID Local</th><td>{{ individual.id_local }}</td></tr>
                    <tr><th>Nombre</th><td>{{ individual.nombre }}</td></tr>
                    <tr><th>Arrendatario</th><td>{{ individual.arrendatario || '-' }}</td></tr>
                    <tr><th>Domicilio</th><td>{{ individual.domicilio || '-' }}</td></tr>
                    <tr><th>Superficie</th><td>{{ individual.superficie }} m²</td></tr>
                    <tr><th>Giro</th><td>{{ individual.giro }}</td></tr>
                  </table>
                </div>
                <div class="col-md-6">
                  <table class="table table-sm table-bordered">
                    <tr><th width="40%">Vigencia</th><td>{{ individual.vigencia }}</td></tr>
                    <tr><th>Clave Cuota</th><td>{{ individual.clave_cuota }}</td></tr>
                    <tr><th>Fecha Alta</th><td>{{ formatDate(individual.fecha_alta) }}</td></tr>
                    <tr><th>Fecha Baja</th><td>{{ formatDate(individual.fecha_baja) || '-' }}</td></tr>
                    <tr><th>Actualización</th><td>{{ formatDate(individual.fecha_modificacion) }}</td></tr>
                    <tr><th>Sector/Zona</th><td>{{ individual.sector }} / {{ individual.zona }}</td></tr>
                  </table>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Modal de Mensajes -->
        <div v-if="showMessageModal" class="modal fade show d-block" tabindex="-1">
          <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
              <div class="modal-header" :class="messageModal.headerClass">
                <h5 class="modal-title">{{ messageModal.title }}</h5>
                <button type="button" class="btn-close" @click="showMessageModal = false"></button>
              </div>
              <div class="modal-body">
                <p class="mb-0">{{ messageModal.message }}</p>
              </div>
              <div class="modal-footer">
                <button type="button" class="btn btn-secondary" @click="showMessageModal = false">Cerrar</button>
              </div>
            </div>
          </div>
        </div>
        <div v-if="showMessageModal" class="modal-backdrop fade show"></div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';

const loading = ref(false);
const opcion = ref('');
const recaudadoras = ref([]);
const mercados = ref([]);
const resultados = ref([]);
const individual = ref(null);

// Modal de mensajes
const showMessageModal = ref(false);
const messageModal = ref({
  title: '',
  message: '',
  headerClass: ''
});

const mostrarMensaje = (mensaje, tipo = 'info') => {
  const config = {
    success: { title: 'Éxito', headerClass: 'bg-success text-white' },
    error: { title: 'Error', headerClass: 'bg-danger text-white' },
    warning: { title: 'Advertencia', headerClass: 'bg-warning text-dark' },
    info: { title: 'Información', headerClass: 'bg-info text-white' }
  };
  messageModal.value = {
    title: config[tipo].title,
    message: mensaje,
    headerClass: config[tipo].headerClass
  };
  showMessageModal.value = true;
};

const form = ref({
  oficina: '',
  num_mercado: '',
  categoria: '',
  seccion: '',
  local: '',
  letra_local: '',
  bloque: '',
  nombre: ''
});

const formatDate = (value) => {
  if (!value) return '';
  return new Date(value).toLocaleDateString('es-MX');
};

const fetchRecaudadoras = async () => {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_get_recaudadoras',
        Base: 'padron_licencias',
        Parametros: []
      }
    });
    if (response.data.eResponse?.success) {
      recaudadoras.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar recaudadoras:', error);
  }
};

const onOficinaChange = async () => {
  mercados.value = [];
  form.value.num_mercado = '';
  if (!form.value.oficina) return;

  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consulta_locales_get_mercados',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_oficina', Valor: parseInt(form.value.oficina) }
        ]
      }
    });
    if (response.data.eResponse?.success) {
      mercados.value = response.data.eResponse.data.result || [];
    }
  } catch (error) {
    console.error('Error al cargar mercados:', error);
  }
};

const buscar = async () => {
  if (!opcion.value) {
    mostrarMensaje('Seleccione un tipo de búsqueda', 'warning');
    return;
  }

  loading.value = true;
  resultados.value = [];
  individual.value = null;

  try {
    if (opcion.value === 'L') {
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_consulta_locales_buscar',
          Base: 'padron_licencias',
          Parametros: [
            { Nombre: 'p_oficina', Valor: form.value.oficina ? parseInt(form.value.oficina) : null },
            { Nombre: 'p_num_mercado', Valor: form.value.num_mercado ? parseInt(form.value.num_mercado) : null },
            { Nombre: 'p_categoria', Valor: form.value.categoria ? parseInt(form.value.categoria) : null },
            { Nombre: 'p_seccion', Valor: form.value.seccion || null },
            { Nombre: 'p_local', Valor: form.value.local ? parseInt(form.value.local) : null },
            { Nombre: 'p_letra_local', Valor: form.value.letra_local || null },
            { Nombre: 'p_bloque', Valor: form.value.bloque || null }
          ]
        }
      });
      if (response.data.eResponse?.success) {
        resultados.value = response.data.eResponse.data.result || [];
        if (resultados.value.length === 0) {
          mostrarMensaje('No se encontraron locales con los criterios especificados', 'info');
        }
      }
    } else if (opcion.value === 'N') {
      if (!form.value.nombre) {
        mostrarMensaje('Ingrese un nombre para buscar', 'warning');
        loading.value = false;
        return;
      }
      const response = await axios.post('/api/generic', {
        eRequest: {
          Operacion: 'sp_consulta_locales_buscar_nombre',
          Base: 'padron_licencias',
          Parametros: [
            { Nombre: 'p_nombre', Valor: form.value.nombre }
          ]
        }
      });
      if (response.data.eResponse?.success) {
        resultados.value = response.data.eResponse.data.result || [];
        if (resultados.value.length === 0) {
          mostrarMensaje('No se encontraron locales con el nombre especificado', 'info');
        }
      }
    }
  } catch (error) {
    console.error('Error al buscar:', error);
    mostrarMensaje('Error al buscar locales', 'error');
  } finally {
    loading.value = false;
  }
};

const verIndividual = async (id_local) => {
  try {
    const response = await axios.post('/api/generic', {
      eRequest: {
        Operacion: 'sp_consulta_locales_get_individual',
        Base: 'padron_licencias',
        Parametros: [
          { Nombre: 'p_id_local', Valor: id_local }
        ]
      }
    });
    if (response.data.eResponse?.success) {
      const result = response.data.eResponse.data.result || [];
      individual.value = result[0] || null;
    }
  } catch (error) {
    console.error('Error al cargar detalle:', error);
  }
};

const limpiar = () => {
  form.value = {
    oficina: '',
    num_mercado: '',
    categoria: '',
    seccion: '',
    local: '',
    letra_local: '',
    bloque: '',
    nombre: ''
  };
  resultados.value = [];
  individual.value = null;
  opcion.value = '';
  mercados.value = [];
};

onMounted(() => {
  fetchRecaudadoras();
});
</script>
