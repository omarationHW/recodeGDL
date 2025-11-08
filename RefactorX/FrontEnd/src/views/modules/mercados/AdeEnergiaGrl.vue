<template>
  <div class="ade-energia-grl-page">
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Reportes</span> &gt; <span>Adeudos Generales de Energía</span>
    </div>
    <h1>Adeudos Generales de Energía</h1>
    <div class="form-section">
      <div class="form-row">
        <label for="recaudadora">Oficina</label>
        <select v-model="selectedRec" @change="onRecChange">
          <option value="" disabled>Seleccione...</option>
          <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
        </select>
        <label for="mercado">Mercado</label>
        <select v-model="selectedMercado">
          <option value="" disabled>Seleccione...</option>
          <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">{{ merc.num_mercado_nvo }} - {{ merc.descripcion }}</option>
        </select>
      </div>
      <div class="form-row">
        <label for="axo">Año Hasta:</label>
        <input type="number" v-model.number="axo" min="1995" max="2999" />
        <label for="mes">Mes Hasta:</label>
        <input type="number" v-model.number="mes" min="1" max="12" />
        <button @click="buscar" :disabled="loading">Buscar</button>
        <button @click="exportarExcel" :disabled="!adeudos.length">Excel</button>
        <button @click="imprimir" :disabled="!adeudos.length">Imprimir</button>
      </div>
    </div>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="adeudos.length" class="table-section">
      <table class="adeudos-table">
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
            <td>{{ row.mesesadeudos }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AdeEnergiaGrlPage',
  data() {
    return {
      recaudadoras: [],
      mercados: [],
      selectedRec: '',
      selectedMercado: '',
      axo: new Date().getFullYear(),
      mes: new Date().getMonth() + 1,
      adeudos: [],
      loading: false,
      error: ''
    };
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return '$' + val.toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  },
  mounted() {
    this.fetchRecaudadoras();
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.getRecaudadoras',
          payload: {}
        });
        if (res.data.status === 'success') {
          this.recaudadoras = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar recaudadoras';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },
    async onRecChange() {
      this.selectedMercado = '';
      this.mercados = [];
      if (!this.selectedRec) return;
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.getMercadosByRecaudadora',
          payload: { id_rec: this.selectedRec }
        });
        if (res.data.status === 'success') {
          this.mercados = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar mercados';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },
    async buscar() {
      if (!this.selectedRec || !this.selectedMercado || !this.axo || !this.mes) {
        this.error = 'Debe seleccionar recaudadora, mercado, año y mes.';
        return;
      }
      this.loading = true;
      this.error = '';
      this.adeudos = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'mercados.getAdeudosEnergiaGrl',
          payload: {
            id_rec: this.selectedRec,
            num_mercado_nvo: this.selectedMercado,
            axo: this.axo,
            mes: this.mes
          }
        });
        if (res.data.status === 'success') {
          this.adeudos = res.data.data;
        } else {
          this.error = res.data.message || 'Error al consultar adeudos';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },
    exportarExcel() {
      // Puede implementarse con una llamada a un endpoint de exportación
      alert('Funcionalidad de exportación a Excel no implementada.');
    },
    imprimir() {
      // Puede implementarse con una llamada a un endpoint de impresión
      alert('Funcionalidad de impresión no implementada.');
    }
  }
};
</script>

<style scoped>
.ade-energia-grl-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1.5rem;
}
.breadcrumb {
  font-size: 0.9rem;
  color: #888;
  margin-bottom: 1rem;
}
.form-section {
  background: #f8f8f8;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 1.5rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 0.5rem;
}
.form-row label {
  min-width: 90px;
}
.form-row input, .form-row select {
  min-width: 80px;
  padding: 0.2rem 0.5rem;
}
.table-section {
  overflow-x: auto;
}
.adeudos-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1rem;
}
.adeudos-table th, .adeudos-table td {
  border: 1px solid #ccc;
  padding: 0.4rem 0.6rem;
  text-align: left;
}
.adeudos-table th {
  background: #eaeaea;
}
.loading {
  color: #0074d9;
  font-weight: bold;
}
.error {
  color: #c00;
  font-weight: bold;
  margin-top: 1rem;
}
</style>
