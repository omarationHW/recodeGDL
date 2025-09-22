<template>
  <div class="cons-contratos-page">
    <h1>Consulta de Contratos</h1>
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Convenios</span> &gt; <span>Consulta de Contratos</span>
    </div>
    <div class="search-section">
      <label>
        <input type="radio" v-model="searchType" value="contrato" /> Contrato
      </label>
      <label>
        <input type="radio" v-model="searchType" value="nombre" /> Nombre
      </label>
      <label>
        <input type="radio" v-model="searchType" value="domicilio" /> Domicilio
      </label>
      <div v-if="searchType === 'contrato'">
        <input v-model="form.colonia" placeholder="Colonia" maxlength="3" />
        <input v-model="form.calle" placeholder="Calle" maxlength="3" />
        <input v-model="form.folio" placeholder="Folio" maxlength="6" />
      </div>
      <div v-if="searchType === 'nombre'">
        <input v-model="form.nombre" placeholder="Nombre" maxlength="60" />
      </div>
      <div v-if="searchType === 'domicilio'">
        <input v-model="form.desc_calle" placeholder="Domicilio" maxlength="50" />
        <input v-model="form.numero" placeholder="Número" maxlength="11" />
      </div>
      <button @click="buscar">Buscar</button>
      <button @click="limpiar">Limpiar</button>
    </div>
    <div v-if="loading" class="loading">Buscando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="resultados.length > 0">
      <h2>Resultados</h2>
      <table class="results-table">
        <thead>
          <tr>
            <th>Colonia</th>
            <th>Calle</th>
            <th>Folio</th>
            <th>Nombre</th>
            <th>Domicilio</th>
            <th>Número</th>
            <th>Acción</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="contrato in resultados" :key="contrato.id_convenio">
            <td>{{ contrato.colonia }}</td>
            <td>{{ contrato.calle }}</td>
            <td>{{ contrato.folio }}</td>
            <td>{{ contrato.nombre }}</td>
            <td>{{ contrato.desc_calle }}</td>
            <td>{{ contrato.numero }}</td>
            <td>
              <button @click="verDetalle(contrato.id_convenio)">Ver Detalle</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="detalle">
      <h2>Detalle del Contrato</h2>
      <div class="detalle-grid">
        <div><strong>Colonia:</strong> {{ detalle.colonia }}</div>
        <div><strong>Calle:</strong> {{ detalle.calle }}</div>
        <div><strong>Folio:</strong> {{ detalle.folio }}</div>
        <div><strong>Nombre:</strong> {{ detalle.nombre }}</div>
        <div><strong>Domicilio:</strong> {{ detalle.desc_calle }}</div>
        <div><strong>Número:</strong> {{ detalle.numero }}</div>
        <div><strong>Tipo Casa:</strong> {{ detalle.tipo_casa }}</div>
        <div><strong>Metros Frente:</strong> {{ detalle.mtrs_frente }}</div>
        <div><strong>Metros Ancho:</strong> {{ detalle.mtrs_ancho }}</div>
        <div><strong>Metros2:</strong> {{ detalle.metros2 }}</div>
        <div><strong>Entre Calle 1:</strong> {{ detalle.entre_calle_1 }}</div>
        <div><strong>Entre Calle 2:</strong> {{ detalle.entre_calle_2 }}</div>
        <div><strong>Pago Total:</strong> {{ detalle.pago_total }}</div>
        <div><strong>Pago Inicial:</strong> {{ detalle.pago_inicial }}</div>
        <div><strong>Pago Quincenal:</strong> {{ detalle.pago_quincenal }}</div>
        <div><strong>Pagos Parciales:</strong> {{ detalle.pagos_parciales }}</div>
        <div><strong>Fecha Firma:</strong> {{ detalle.fecha_firma }}</div>
        <div><strong>Fecha Vencimiento:</strong> {{ detalle.fecha_vencimiento }}</div>
        <div><strong>Vigencia:</strong> {{ detalle.vigencia }}</div>
        <div><strong>Observaciones:</strong> {{ detalle.observacion }}</div>
        <!-- Agregar más campos según sea necesario -->
      </div>
      <button @click="detalle = null">Cerrar Detalle</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsContratosPage',
  data() {
    return {
      searchType: 'contrato',
      form: {
        colonia: '',
        calle: '',
        folio: '',
        nombre: '',
        desc_calle: '',
        numero: ''
      },
      resultados: [],
      detalle: null,
      loading: false,
      error: ''
    };
  },
  methods: {
    async buscar() {
      this.loading = true;
      this.error = '';
      this.resultados = [];
      this.detalle = null;
      let action = '';
      let params = {};
      if (this.searchType === 'contrato') {
        action = 'searchByContrato';
        params = {
          colonia: this.form.colonia || 0,
          calle: this.form.calle || 0,
          folio: this.form.folio || 0
        };
      } else if (this.searchType === 'nombre') {
        action = 'searchByNombre';
        params = { nombre: this.form.nombre };
      } else if (this.searchType === 'domicilio') {
        action = 'searchByDomicilio';
        params = {
          desc_calle: this.form.desc_calle,
          numero: this.form.numero
        };
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: `convenios.${action}`,
          payload: params
        });
        if (res.data.status === 'success') {
          this.resultados = res.data.data;
        } else {
          this.error = res.data.message || 'Error en la búsqueda';
        }
      } catch (error) {
        this.error = 'Error de red o servidor';
      }
      this.loading = false;
    },
    limpiar() {
      this.form = {
        colonia: '',
        calle: '',
        folio: '',
        nombre: '',
        desc_calle: '',
        numero: ''
      };
      this.resultados = [];
      this.detalle = null;
      this.error = '';
    },
    async verDetalle(id_convenio) {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'convenios.getContratoDetalle',
          payload: { id_convenio }
        });
        if (res.data.status === 'success' && res.data.data && res.data.data.length > 0) {
          this.detalle = res.data.data[0];
        } else {
          this.error = res.data.message || 'No se encontró el detalle';
        }
      } catch (error) {
        this.error = 'Error de red o servidor';
      }
      this.loading = false;
    }
  }
};
</script>

<style scoped>
.cons-contratos-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  font-size: 0.9rem;
  color: #888;
  margin-bottom: 1rem;
}
.search-section {
  background: #f8f8f8;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 1.5rem;
}
.search-section input[type="text"] {
  margin-right: 0.5rem;
  margin-bottom: 0.5rem;
  padding: 0.3rem 0.5rem;
}
.search-section button {
  margin-left: 0.5rem;
}
.loading {
  color: #007bff;
  margin: 1rem 0;
}
.error {
  color: #c00;
  margin: 1rem 0;
}
.results-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.results-table th, .results-table td {
  border: 1px solid #ddd;
  padding: 0.5rem;
}
.results-table th {
  background: #f0f0f0;
}
.detalle-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.5rem 2rem;
  background: #f9f9f9;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 1rem;
}
</style>
