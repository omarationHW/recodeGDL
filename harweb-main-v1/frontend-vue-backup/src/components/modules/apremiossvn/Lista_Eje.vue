<template>
  <div class="lista-eje-page">
    <h1>Catálogo de Ejecutores</h1>
    <div class="actions">
      <label>
        <input type="radio" v-model="filtroVigentes" :value="false" /> Todos
      </label>
      <label>
        <input type="radio" v-model="filtroVigentes" :value="true" /> Vigentes
      </label>
      <button @click="imprimirLista">Imprimir Lista</button>
      <button @click="exportarExcel">Exportar a Excel</button>
      <button @click="goBack">Salir</button>
    </div>
    <table class="table table-striped table-bordered mt-3">
      <thead>
        <tr>
          <th>Cve Ejecutor</th>
          <th>Iniciales RFC</th>
          <th>Fecha RFC</th>
          <th>Homoclave</th>
          <th>Nombre</th>
          <th>Recaudadora</th>
          <th>Oficio</th>
          <th>Fecha Inicio</th>
          <th>Fecha Termino</th>
          <th>Vigencia</th>
          <th>Observación</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in listaFiltrada" :key="row.id_ejecutor">
          <td>{{ row.cve_eje }}</td>
          <td>{{ row.ini_rfc }}</td>
          <td>{{ row.fec_rfc }}</td>
          <td>{{ row.hom_rfc }}</td>
          <td>{{ row.nombre }}</td>
          <td>{{ row.id_rec }}</td>
          <td>{{ row.oficio }}</td>
          <td>{{ row.fecinic }}</td>
          <td>{{ row.fecterm }}</td>
          <td>{{ row.vigencia }}</td>
          <td>{{ row.observacion }}</td>
        </tr>
      </tbody>
    </table>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'ListaEjePage',
  data() {
    return {
      lista: [],
      filtroVigentes: false,
      loading: false,
      error: null
    };
  },
  computed: {
    listaFiltrada() {
      if (this.filtroVigentes) {
        return this.lista.filter(row => row.vigencia === 'A');
      }
      return this.lista;
    }
  },
  methods: {
    fetchLista() {
      this.loading = true;
      this.error = null;
      this.$axios.post('/api/execute', {
        action: 'get_lista_eje',
        params: {
          rec: 1,
          rec1: 9
        }
      })
      .then(res => {
        if (res.data.status === 'success') {
          this.lista = res.data.data;
        } else {
          this.error = res.data.message;
        }
      })
      .catch(err => {
        this.error = err.message;
      })
      .finally(() => {
        this.loading = false;
      });
    },
    imprimirLista() {
      // Simulación de impresión
      window.print();
    },
    exportarExcel() {
      // Simulación de exportación
      alert('Exportación a Excel simulada.');
    },
    goBack() {
      this.$router.push('/');
    }
  },
  watch: {
    filtroVigentes() {
      // No es necesario volver a cargar, solo filtra localmente
    }
  },
  mounted() {
    this.fetchLista();
  }
};
</script>

<style scoped>
.lista-eje-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.actions {
  margin-bottom: 1rem;
  display: flex;
  gap: 1rem;
  align-items: center;
}
.loading {
  color: #007bff;
  margin-top: 1rem;
}
.error {
  color: #dc3545;
  margin-top: 1rem;
}
</style>
