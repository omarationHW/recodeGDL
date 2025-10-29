<template>
  <div class="adeudos-energia-page">
    <h1 class="mb-4">Listado de Adeudos de Energía Eléctrica</h1>
    <div class="filters mb-3">
      <div class="row">
        <div class="col-md-2">
          <label class="municipal-form-label">Oficina</label>
          <select v-model="selectedOficina" @change="fetchMercados" class="municipal-form-control">
            <option v-for="of in oficinas" :key="of.id_rec" :value="of.id_rec">{{ of.recaudadora }}</option>
          </select>
        </div>
        <div class="col-md-4">
          <label class="municipal-form-label">Mercado</label>
          <select v-model="selectedMercado" class="municipal-form-control">
            <option v-for="m in mercados" :key="m.num_mercado_nvo" :value="m.num_mercado_nvo">{{ m.num_mercado_nvo }} - {{ m.descripcion }}</option>
          </select>
        </div>
        <div class="col-md-2">
          <label class="municipal-form-label">Año</label>
          <input type="number" v-model.number="axo" class="municipal-form-control" min="1994" max="2999" />
        </div>
        <div class="col-md-2">
          <label class="municipal-form-label">Mes</label>
          <input type="number" v-model.number="mes" class="municipal-form-control" min="1" max="12" />
        </div>
        <div class="col-md-2 d-flex align-items-end">
          <button class="btn btn-municipal-primary w-100" @click="fetchAdeudos">Buscar</button>
        </div>
      </div>
    </div>
    <div class="mb-2">
      <button class="btn btn-municipal-success" @click="exportExcel">Exportar a Excel</button>
    </div>
    <div class="table-responsive">
      <table class="-bordered municipal-table-striped">
        <thead>
          <tr>
            <th>Rec.</th>
            <th>Merc.</th>
            <th>Cat.</th>
            <th>Sec.</th>
            <th>Local</th>
            <th>Letra</th>
            <th>Bloque</th>
            <th>Nombre</th>
            <th>Adicionales</th>
            <th>Cuota Bim/Mes</th>
            <th>Año</th>
            <th>Adeudo</th>
            <th>Periodo de Adeudo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in adeudos" :key="row.id_local + '-' + row.id_energia">
            <td>{{ row.oficina }}</td>
            <td>{{ row.num_mercado }}</td>
            <td>{{ row.categoria }}</td>
            <td>{{ row.seccion }}</td>
            <td>{{ row.local }}</td>
            <td>{{ row.letra_local }}</td>
            <td>{{ row.bloque }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.local_adicional }}</td>
            <td>{{ row.cuota | currency }}</td>
            <td>{{ row.axo }}</td>
            <td>{{ row.adeudo | currency }}</td>
            <td>
              <span v-if="row.mesesadeudos">{{ row.mesesadeudos }}</span>
              <button class="btn btn-link btn-sm" @click="showMeses(row)">Ver</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <b-modal v-model="showMesesModal" title="Meses de Adeudo" hide-footer>
      <div v-if="mesesAdeudo.length">
        <ul>
          <li v-for="m in mesesAdeudo" :key="m.periodo">{{ m.periodo }} - {{ m.importe | currency }}</li>
        </ul>
      </div>
      <div v-else>
        <em>No hay información de meses de adeudo.</em>
      </div>
    </b-modal>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'AdeudosEnergiaPage',
  data() {
    return {
      oficinas: [],
      mercados: [],
      selectedOficina: null,
      selectedMercado: null,
      axo: new Date().getFullYear(),
      mes: new Date().getMonth() + 1,
      adeudos: [],
      showMesesModal: false,
      mesesAdeudo: []
    };
  },
  filters: {
    currency(val) {
      if (typeof val === 'number') return '$' + val.toFixed(2);
      return val;
    }
  },
  mounted() {
    this.fetchOficinas();
  },
  methods: {
    async fetchOficinas() {
      const res = await axios.post('/api/execute', {
        eRequest: { action: 'getOficinas' }
      });
      this.oficinas = res.data.eResponse.result;
      if (this.oficinas.length) {
        this.selectedOficina = this.oficinas[0].id_rec;
        this.fetchMercados();
      }
    },
    async fetchMercados() {
      if (!this.selectedOficina) return;
      const res = await axios.post('/api/execute', {
        eRequest: { action: 'getMercadosByOficina', params: { oficina: this.selectedOficina } }
      });
      this.mercados = res.data.eResponse.result;
      if (this.mercados.length) {
        this.selectedMercado = this.mercados[0].num_mercado_nvo;
      }
    },
    async fetchAdeudos() {
      if (!this.selectedOficina || !this.selectedMercado || !this.axo || !this.mes) return;
      const res = await axios.post('/api/execute', {
        eRequest: {
          action: 'getAdeudosEnergia',
          params: {
            oficina: this.selectedOficina,
            mercado: this.selectedMercado,
            axo: this.axo,
            mes: this.mes
          }
        }
      });
      this.adeudos = res.data.eResponse.result || [];
    },
    async showMeses(row) {
      const res = await axios.post('/api/execute', {
        eRequest: {
          action: 'getMesesAdeudoEnergia',
          params: {
            id_energia: row.id_energia,
            axo: this.axo,
            mes: this.mes
          }
        }
      });
      this.mesesAdeudo = res.data.eResponse.result || [];
      this.showMesesModal = true;
    },
    exportExcel() {
      // Puede implementarse usando FileSaver.js o similar
      alert('Funcionalidad de exportación a Excel no implementada en este demo.');
    }
  }
};
</script>

<style scoped>
.adeudos-energia-page {
  padding: 2rem;
}
.filters label {
  font-weight: bold;
}
.table th, .table td {
  font-size: 0.95rem;
}
</style>
