<template>
  <div class="padron-locales-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Padrón de Locales</li>
      </ol>
    </nav>
    <h2>Padrón de Arrendamiento de Mercados</h2>
    <form @submit.prevent="fetchPadronLocales">
      <div class="row mb-3">
        <div class="col-md-4">
          <label for="oficina">Oficina Recaudadora</label>
          <select v-model="form.oficina" id="oficina" class="form-control" required>
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
              {{ rec.recaudadora }}
            </option>
          </select>
        </div>
        <div class="col-md-4">
          <label for="mercado">Mercado</label>
          <select v-model="form.mercado" id="mercado" class="form-control" required>
            <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">
              {{ merc.descripcion }}
            </option>
          </select>
        </div>
        <div class="col-md-4 align-self-end">
          <button type="submit" class="btn btn-primary">Consultar</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="padronLocales.length">
      <h4 class="mt-4">Locales encontrados: {{ padronLocales.length }}</h4>
      <table class="table table-bordered table-sm mt-2">
        <thead class="thead-light">
          <tr>
            <th>Local</th>
            <th>Adicionales</th>
            <th>Nombre</th>
            <th>Superficie</th>
            <th>Alta</th>
            <th>Baja</th>
            <th>Vigencia</th>
            <th>Renta</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="local in padronLocales" :key="local.id_local">
            <td>{{ local.datosmercado }}</td>
            <td>{{ local.descripcion_local }}</td>
            <td>{{ local.nombre }}</td>
            <td class="text-right">{{ local.superficie.toFixed(2) }}</td>
            <td>{{ local.fecha_alta | fecha }}</td>
            <td>{{ local.fecha_baja ? (local.fecha_baja | fecha) : '' }}</td>
            <td>{{ local.vigdescripcion }}</td>
            <td class="text-right">{{ local.renta ? local.renta.toFixed(2) : '' }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total de Locales:</strong> {{ padronLocales.length }}<br>
        <strong>Total de Superficie:</strong> {{ totalSuperficie.toFixed(2) }}<br>
        <strong>Total de Renta:</strong> {{ totalRenta.toFixed(2) }}
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'PadronLocalesPage',
  data() {
    return {
      form: {
        oficina: '',
        mercado: ''
      },
      recaudadoras: [],
      mercados: [],
      padronLocales: [],
      loading: false,
      error: '',
      totalSuperficie: 0,
      totalRenta: 0
    };
  },
  filters: {
    fecha(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    }
  },
  created() {
    this.fetchRecaudadoras();
  },
  watch: {
    'form.oficina'(val) {
      if (val) this.fetchMercados(val);
    }
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      try {
        const res = await axios.post('/api/execute', {
          action: 'getRecaudadora',
          params: {}
        });
        this.recaudadoras = res.data.data || [];
        if (this.recaudadoras.length) {
          this.form.oficina = this.recaudadoras[0].id_rec;
        }
      } catch (e) {
        this.error = 'Error al cargar recaudadoras';
      } finally {
        this.loading = false;
      }
    },
    async fetchMercados(oficina) {
      this.loading = true;
      try {
        const res = await axios.post('/api/execute', {
          action: 'getMercado',
          params: { oficina }
        });
        this.mercados = res.data.data || [];
        if (this.mercados.length) {
          this.form.mercado = this.mercados[0].num_mercado_nvo;
        }
      } catch (e) {
        this.error = 'Error al cargar mercados';
      } finally {
        this.loading = false;
      }
    },
    async fetchPadronLocales() {
      this.loading = true;
      this.error = '';
      this.padronLocales = [];
      this.totalSuperficie = 0;
      this.totalRenta = 0;
      try {
        const res = await axios.post('/api/execute', {
          action: 'getPadronLocales',
          params: {
            oficina: this.form.oficina,
            mercado: this.form.mercado
          }
        });
        this.padronLocales = res.data.data || [];
        // Calcular totales
        let totalSup = 0, totalRenta = 0;
        for (const l of this.padronLocales) {
          totalSup += parseFloat(l.superficie || 0);
          totalRenta += parseFloat(l.renta || 0);
        }
        this.totalSuperficie = totalSup;
        this.totalRenta = totalRenta;
      } catch (e) {
        this.error = 'Error al consultar padrón de locales';
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.padron-locales-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
