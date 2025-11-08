<template>
  <div class="consulta-datos-locales">
    <div class="breadcrumb">
      <span>Inicio</span> &gt; <span>Consulta de Datos Generales de Locales</span>
    </div>
    <h2>Consulta de Datos Generales de Locales</h2>
    <div class="panel-superior">
      <form @submit.prevent="onBuscar">
        <fieldset>
          <legend>Clasificación</legend>
          <div class="form-row">
            <label><input type="radio" v-model="opcion" value="L" @change="onOpcionChange"> Local</label>
            <label><input type="radio" v-model="opcion" value="N" @change="onOpcionChange"> Nombre</label>
          </div>
          <div v-if="opcion==='L'" class="form-row">
            <select v-model="form.oficina" @change="onOficinaChange">
              <option value="">Recaudadora</option>
              <option v-for="rec in catalogos.recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }}</option>
            </select>
            <select v-model="form.num_mercado">
              <option value="">Mercado</option>
              <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">{{ merc.num_mercado_nvo }} - {{ merc.descripcion }}</option>
            </select>
            <input v-model="form.categoria" placeholder="Cat" maxlength="1" style="width:40px" />
            <select v-model="form.seccion">
              <option value="">Sección</option>
              <option v-for="sec in catalogos.secciones" :key="sec.seccion" :value="sec.seccion">{{ sec.seccion }}</option>
            </select>
            <input v-model="form.local" placeholder="Local" style="width:60px" />
            <input v-model="form.letra_local" placeholder="Letra" maxlength="1" style="width:40px" />
            <input v-model="form.bloque" placeholder="Blq" maxlength="1" style="width:40px" />
          </div>
          <div v-if="opcion==='N'" class="form-row">
            <input v-model="form.nombre" placeholder="Nombre" style="width:300px" />
          </div>
          <div class="form-row">
            <button type="submit">Buscar</button>
            <button type="button" @click="onLimpiar">Limpiar</button>
          </div>
        </fieldset>
      </form>
    </div>
    <div class="panel-central" v-if="resultados.length">
      <h3>Resultados</h3>
      <table class="resultados">
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
            <td>{{ row.letra_local }}</td>
            <td>{{ row.bloque }}</td>
            <td>{{ row.nombre }}</td>
            <td><button @click="verIndividual(row.id_local)">Ver</button></td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="individual" class="panel-individual">
      <h3>Datos Individuales del Local</h3>
      <pre>{{ individual }}</pre>
      <button @click="individual=null">Cerrar</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsultaDatosLocales',
  data() {
    return {
      opcion: '',
      form: {
        oficina: '',
        num_mercado: '',
        categoria: '',
        seccion: '',
        local: '',
        letra_local: '',
        bloque: '',
        nombre: ''
      },
      catalogos: {
        recaudadoras: [],
        secciones: []
      },
      mercados: [],
      resultados: [],
      individual: null
    }
  },
  mounted() {
    this.loadCatalogos();
  },
  methods: {
    async loadCatalogos() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getCatalogos' })
      });
      const data = await res.json();
      if (data.success) {
        this.catalogos.recaudadoras = data.data.recaudadoras;
        this.catalogos.secciones = data.data.secciones;
      }
    },
    async onOficinaChange() {
      if (!this.form.oficina) {
        this.mercados = [];
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getMercadosPorOficina', params: { oficina: this.form.oficina } })
      });
      const data = await res.json();
      if (data.success) {
        this.mercados = data.data;
      }
    },
    onOpcionChange() {
      this.resultados = [];
      this.individual = null;
    },
    async onBuscar() {
      this.resultados = [];
      this.individual = null;
      if (this.opcion === 'L') {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'buscarLocales',
            params: {
              oficina: this.form.oficina,
              num_mercado: this.form.num_mercado,
              categoria: this.form.categoria,
              seccion: this.form.seccion,
              local: this.form.local,
              letra_local: this.form.letra_local,
              bloque: this.form.bloque,
              orden: 'oficina,num_mercado,categoria,seccion,local,letra_local,bloque'
            }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.resultados = data.data;
        }
      } else if (this.opcion === 'N') {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            action: 'buscarPorNombre',
            params: { nombre: this.form.nombre }
          })
        });
        const data = await res.json();
        if (data.success) {
          this.resultados = data.data;
        }
      }
    },
    onLimpiar() {
      this.form = {
        oficina: '',
        num_mercado: '',
        categoria: '',
        seccion: '',
        local: '',
        letra_local: '',
        bloque: '',
        nombre: ''
      };
      this.resultados = [];
      this.individual = null;
      this.opcion = '';
    },
    async verIndividual(id_local) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getLocalIndividual', params: { id_local } })
      });
      const data = await res.json();
      if (data.success) {
        this.individual = data.data[0] || data.data;
      }
    }
  }
}
</script>

<style scoped>
.consulta-datos-locales {
  max-width: 1100px;
  margin: 0 auto;
  padding: 1.5rem;
}
.breadcrumb {
  font-size: 0.95em;
  color: #888;
  margin-bottom: 1em;
}
.panel-superior {
  background: #f8f8f8;
  padding: 1em;
  border-radius: 6px;
  margin-bottom: 1em;
}
fieldset {
  border: 1px solid #ccc;
  border-radius: 6px;
  padding: 1em;
}
.form-row {
  display: flex;
  gap: 0.5em;
  margin-bottom: 0.7em;
  align-items: center;
}
.resultados {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1em;
}
.resultados th, .resultados td {
  border: 1px solid #ddd;
  padding: 0.4em 0.7em;
}
.resultados th {
  background: #f0f0f0;
}
.panel-individual {
  background: #f9f9f9;
  border: 1px solid #ccc;
  padding: 1em;
  margin-top: 1em;
  border-radius: 6px;
}
</style>
