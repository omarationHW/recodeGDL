<template>
  <div class="busca-page">
    <h1>Consulta Convenios</h1>
    <nav class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Consulta Convenios</span>
    </nav>
    <div class="search-section">
      <h2>Búsqueda</h2>
      <form @submit.prevent="onSearch">
        <div class="form-group">
          <label for="tipoBusqueda">Tipo de búsqueda</label>
          <select v-model="tipoBusqueda" id="tipoBusqueda" required>
            <option value="nombre">Por Nombre</option>
            <option value="domicilio">Por Domicilio</option>
            <option value="cuenta">Por Cuenta</option>
            <option value="licencia">Por Licencia de Giro</option>
            <option value="anuncio">Por Licencia de Anuncio</option>
            <option value="multa">Por Multa</option>
            <!-- Agregar más opciones según sea necesario -->
          </select>
        </div>
        <div v-if="tipoBusqueda === 'nombre'">
          <label>Nombre del Contribuyente</label>
          <input v-model="form.nombre" type="text" maxlength="255" required />
        </div>
        <div v-if="tipoBusqueda === 'domicilio'">
          <label>Calle</label>
          <input v-model="form.calle" type="text" maxlength="255" required />
          <label>Número Exterior</label>
          <input v-model.number="form.num_exterior" type="number" min="0" />
        </div>
        <div v-if="tipoBusqueda === 'cuenta'">
          <label>Recaudadora</label>
          <input v-model.number="form.rec" type="number" min="0" required />
          <label>U/R</label>
          <input v-model="form.ur" type="text" maxlength="10" required />
          <label>Cuenta</label>
          <input v-model.number="form.cuenta" type="number" min="0" required />
        </div>
        <div v-if="tipoBusqueda === 'licencia'">
          <label>Número de Licencia</label>
          <input v-model.number="form.licencia" type="number" min="0" required />
        </div>
        <div v-if="tipoBusqueda === 'anuncio'">
          <label>Número de Anuncio</label>
          <input v-model.number="form.anuncio" type="number" min="0" required />
        </div>
        <div v-if="tipoBusqueda === 'multa'">
          <label>Dependencia</label>
          <input v-model="form.dependencia" type="text" maxlength="10" required />
          <label>Año Acta</label>
          <input v-model.number="form.axo_acta" type="number" min="0" required />
          <label>Número Acta</label>
          <input v-model.number="form.num_acta" type="number" min="0" required />
        </div>
        <!-- Agregar más campos según el tipo de búsqueda -->
        <button type="submit">Buscar</button>
      </form>
    </div>
    <div class="results-section" v-if="results && results.length">
      <h2>Resultados</h2>
      <table class="results-table">
        <thead>
          <tr>
            <th>Tipo</th>
            <th>Subtipo</th>
            <th>Let Exp</th>
            <th>Num Oficio</th>
            <th>Año Oficio</th>
            <th>Nombre</th>
            <th>Calle</th>
            <th>Exterior</th>
            <th>Interior</th>
            <th>Inciso</th>
            <th>Manzana</th>
            <th>Lote</th>
            <th>Letra</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in results" :key="row.id_conv_diver">
            <td>{{ row.tipo }}</td>
            <td>{{ row.subtipo }}</td>
            <td>{{ row.letexp }}</td>
            <td>{{ row.numofi }}</td>
            <td>{{ row.aloofi }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.calle }}</td>
            <td>{{ row.num_exterior }}</td>
            <td>{{ row.num_interior }}</td>
            <td>{{ row.inciso }}</td>
            <td>{{ row.manzana }}</td>
            <td>{{ row.lote }}</td>
            <td>{{ row.letra }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="error" class="error-message">
      {{ error }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'BuscaPage',
  data() {
    return {
      tipoBusqueda: 'nombre',
      form: {
        nombre: '',
        calle: '',
        num_exterior: '',
        rec: '',
        ur: '',
        cuenta: '',
        licencia: '',
        anuncio: '',
        dependencia: '',
        axo_acta: '',
        num_acta: ''
      },
      results: [],
      error: ''
    };
  },
  methods: {
    async onSearch() {
      this.error = '';
      this.results = [];
      let action = '';
      let params = {};
      switch (this.tipoBusqueda) {
        case 'nombre':
          action = 'searchByNombre';
          params = { nombre: this.form.nombre };
          break;
        case 'domicilio':
          action = 'searchByDomicilio';
          params = { calle: this.form.calle, num_exterior: this.form.num_exterior };
          break;
        case 'cuenta':
          action = 'searchByCuenta';
          params = { rec: this.form.rec, ur: this.form.ur, cuenta: this.form.cuenta };
          break;
        case 'licencia':
          action = 'searchByLicencia';
          params = { licencia: this.form.licencia };
          break;
        case 'anuncio':
          action = 'searchByAnuncio';
          params = { anuncio: this.form.anuncio };
          break;
        case 'multa':
          action = 'searchByMulta';
          params = { dependencia: this.form.dependencia, axo_acta: this.form.axo_acta, num_acta: this.form.num_acta };
          break;
        // ... otros casos
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: `convenios.${action}`,
          payload: params
        });
        if (res.data.status === 'success') {
          this.results = res.data.data;
        } else {
          this.error = res.data.message || 'Error en la búsqueda';
        }
      } catch (error) {
        this.error = 'Error de conexión con el servidor';
      }
    }
  }
};
</script>

<style scoped>
.busca-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.search-section {
  background: #f9f9f9;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 2rem;
}
.results-section {
  background: #fff;
  padding: 1rem;
  border-radius: 6px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}
.results-table {
  width: 100%;
  border-collapse: collapse;
}
.results-table th, .results-table td {
  border: 1px solid #ddd;
  padding: 0.5rem;
}
.results-table th {
  background: #f0f0f0;
}
.error-message {
  color: red;
  margin-top: 1rem;
}
</style>
