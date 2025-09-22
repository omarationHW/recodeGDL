<template>
  <div class="simulador-convenio-page">
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Simulador de Convenios</span>
    </nav>
    <h1>Simulador de Convenios</h1>
    <div class="actions">
      <button @click="goTo('predial')">Predial</button>
      <button @click="goTo('licencias')">Licencias</button>
      <button @click="goTo('anuncios')">Anuncios</button>
      <button @click="goTo('mercados')">Mercados</button>
      <button @click="goTo('aseo')">Aseo Contratado</button>
      <button @click="goTo('publicos')">Est. Públicos</button>
      <button @click="goTo('exclusivos')">Est. Exclusivos</button>
      <button @click="goTo('obras')">Obras Públicas</button>
    </div>
    <div v-if="step === 1">
      <h2>Selecciona el tipo de convenio</h2>
      <select v-model="modulo" @change="resetForm">
        <option disabled value="">Seleccione...</option>
        <option v-for="(label, key) in modulos" :key="key" :value="key">{{ label }}</option>
      </select>
      <div v-if="modulo">
        <component :is="currentForm" @registro-buscado="onRegistroBuscado" />
      </div>
    </div>
    <div v-if="step === 2">
      <h2>Simulación de Convenio</h2>
      <div v-if="loading">Calculando...</div>
      <div v-else-if="error" class="error">{{ error }}</div>
      <div v-else-if="totales">
        <div class="totales">
          <p><strong>Nombre:</strong> {{ totales.nombre }}</p>
          <p><strong>Domicilio:</strong> {{ totales.calle }} {{ totales.exterior }} {{ totales.interior }}</p>
          <p><strong>Importe:</strong> {{ currency(totales.importe) }}</p>
          <p><strong>Recargos:</strong> {{ currency(totales.recargos) }}</p>
          <p><strong>Actualización:</strong> {{ currency(totales.actualizacion) }}</p>
          <p><strong>Gastos:</strong> {{ currency(totales.gastos) }}</p>
          <p><strong>Multa:</strong> {{ currency(totales.multa) }}</p>
          <p><strong>Total:</strong> <b>{{ currency(totales.total) }}</b></p>
        </div>
        <h3>Parcialidades Simuladas</h3>
        <table class="periodos-table">
          <thead>
            <tr>
              <th>Año</th>
              <th>Mes</th>
              <th>Importe</th>
              <th>Recargos</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="p in periodos" :key="p.id_control">
              <td>{{ p.ayo }}</td>
              <td>{{ p.periodo }}</td>
              <td>{{ currency(p.importe) }}</td>
              <td>{{ currency(p.recargos) }}</td>
            </tr>
          </tbody>
        </table>
        <button @click="resetForm">Nueva Simulación</button>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

// Subcomponentes para cada formulario de búsqueda
import PredialForm from './SimuladorConvenio/PredialForm.vue';
import LicenciasForm from './SimuladorConvenio/LicenciasForm.vue';
import AnunciosForm from './SimuladorConvenio/AnunciosForm.vue';
import MercadosForm from './SimuladorConvenio/MercadosForm.vue';
import AseoForm from './SimuladorConvenio/AseoForm.vue';
import PublicosForm from './SimuladorConvenio/PublicosForm.vue';
import ExclusivosForm from './SimuladorConvenio/ExclusivosForm.vue';
import ObrasForm from './SimuladorConvenio/ObrasForm.vue';

export default {
  name: 'SimuladorConvenioPage',
  components: {
    PredialForm, LicenciasForm, AnunciosForm, MercadosForm, AseoForm, PublicosForm, ExclusivosForm, ObrasForm
  },
  data() {
    return {
      step: 1,
      modulo: '',
      registro: null,
      totales: null,
      periodos: [],
      loading: false,
      error: '',
      modulos: {
        '5': 'Predial',
        '9': 'Licencias',
        '10': 'Anuncios',
        '11': 'Mercados',
        '16': 'Aseo Contratado',
        '24': 'Estacionamiento Público',
        '28': 'Estacionamiento Exclusivo',
        '17': 'Obras Públicas'
      }
    };
  },
  computed: {
    currentForm() {
      switch (this.modulo) {
        case '5': return 'PredialForm';
        case '9': return 'LicenciasForm';
        case '10': return 'AnunciosForm';
        case '11': return 'MercadosForm';
        case '16': return 'AseoForm';
        case '24': return 'PublicosForm';
        case '28': return 'ExclusivosForm';
        case '17': return 'ObrasForm';
        default: return null;
      }
    }
  },
  methods: {
    goTo(tipo) {
      this.modulo = Object.keys(this.modulos).find(k => this.modulos[k].toLowerCase().includes(tipo));
      this.resetForm();
    },
    resetForm() {
      this.step = 1;
      this.registro = null;
      this.totales = null;
      this.periodos = [];
      this.loading = false;
      this.error = '';
    },
    onRegistroBuscado({ id_registro, id_control }) {
      this.loading = true;
      this.error = '';
      // Llama API para simular convenio
      axios.post('/api/execute', {
        eRequest: {
          action: 'simularConvenio',
          modulo: this.modulo,
          id_registro: id_registro
        }
      }).then(res => {
        const resp = res.data.eResponse;
        if (resp.status === 'ok') {
          this.totales = resp.totales;
          // Llama API para listar periodos
          return axios.post('/api/execute', {
            eRequest: {
              action: 'listarPeriodos',
              id_control: id_control
            }
          });
        } else {
          throw new Error(resp.message);
        }
      }).then(res2 => {
        this.periodos = res2.data.eResponse.periodos || [];
        this.step = 2;
        this.loading = false;
      }).catch(err => {
        this.error = err.message || 'Error al simular convenio';
        this.loading = false;
      });
    },
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.simulador-convenio-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.actions {
  margin-bottom: 2rem;
}
.actions button {
  margin-right: 1rem;
}
.totales {
  background: #f8f8f8;
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 2rem;
}
.periodos-table {
  width: 100%;
  border-collapse: collapse;
}
.periodos-table th, .periodos-table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.error {
  color: red;
  font-weight: bold;
}
</style>
