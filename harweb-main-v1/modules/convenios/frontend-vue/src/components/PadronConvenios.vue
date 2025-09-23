<template>
  <div class="padron-convenios-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Padrón de Convenios</li>
      </ol>
    </nav>
    <h2>Padrón de Convenios</h2>
    <form @submit.prevent="buscarConvenios" class="mb-4">
      <div class="row">
        <div class="col-md-3">
          <label>Tipo</label>
          <select v-model="filtros.tipo" @change="onTipoChange" class="form-control">
            <option value="">Seleccione...</option>
            <option v-for="tipo in tipos" :key="tipo.tipo" :value="tipo.tipo">
              {{ tipo.tipo }} - {{ tipo.descripcion }}
            </option>
          </select>
        </div>
        <div class="col-md-3">
          <label>Subtipo</label>
          <select v-model="filtros.subtipo" class="form-control">
            <option value="">Todos los subtipos</option>
            <option v-for="sub in subtipos" :key="sub.subtipo" :value="sub.subtipo">
              {{ sub.subtipo }} - {{ sub.desc_subtipo }}
            </option>
          </select>
        </div>
        <div class="col-md-2">
          <label>Vigencia</label>
          <select v-model="filtros.vigencia" class="form-control">
            <option v-for="vig in vigencias" :key="vig.value" :value="vig.value">{{ vig.label }}</option>
          </select>
        </div>
        <div class="col-md-4">
          <label>Recaudadora</label>
          <select v-model="filtros.recaudadora" class="form-control">
            <option value="">Todas las recaudadoras</option>
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">
              {{ rec.id_rec }} - {{ rec.recaudadora }}
            </option>
          </select>
        </div>
      </div>
      <div class="row mt-2">
        <div class="col-md-2">
          <label>Año desde</label>
          <input type="number" v-model="filtros.anio_desde" class="form-control" min="2005" max="2100">
        </div>
        <div class="col-md-2">
          <label>Año hasta</label>
          <input type="number" v-model="filtros.anio_hasta" class="form-control" min="2005" max="2100">
        </div>
        <div class="col-md-2 align-self-end">
          <button class="btn btn-primary" type="submit">Buscar</button>
        </div>
        <div class="col-md-2 align-self-end">
          <button class="btn btn-success" type="button" @click="exportarExcel" :disabled="!convenios.length">Exportar Excel</button>
        </div>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando datos...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="convenios.length">
      <h5>Resultados ({{ convenios.length }})</h5>
      <table class="table table-bordered table-sm table-hover">
        <thead>
          <tr>
            <th>ID</th>
            <th>Tipo</th>
            <th>Subtipo</th>
            <th>Expediente</th>
            <th>Fecha Inicio</th>
            <th>Fecha Venc.</th>
            <th>Costo</th>
            <th>Descripción</th>
            <th>Vigencia</th>
            <th>Referencia</th>
            <th>Folios</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="conv in convenios" :key="conv.id_conv_resto">
            <td>{{ conv.id_conv_resto }}</td>
            <td>{{ conv.tipo }}</td>
            <td>{{ conv.subtipo }}</td>
            <td>{{ conv.letras_exp }}/{{ conv.numero_exp }}/{{ conv.axo_exp }}</td>
            <td>{{ conv.fecha_inicio | fecha }}</td>
            <td>{{ conv.fecha_venc | fecha }}</td>
            <td>{{ conv.costo | moneda }}</td>
            <td>{{ conv.desc_subtipo }}</td>
            <td>{{ conv.vigencia }}</td>
            <td>{{ conv.referencia }}</td>
            <td>{{ conv.folios }}</td>
            <td>
              <button class="btn btn-link btn-sm" @click="verFolios(conv)">Folios</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="folios.length">
      <h5>Folios del convenio seleccionado</h5>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Folio</th>
            <th>Ejecutor</th>
            <th>Fecha Practicado</th>
            <th>Vigencia</th>
            <th>Periodo Desde</th>
            <th>Periodo Hasta</th>
            <th>Fecha Pago</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="f in folios" :key="f.folio">
            <td>{{ f.folio }}</td>
            <td>{{ f.ejecutor }}</td>
            <td>{{ f.fecprac | fecha }}</td>
            <td>{{ f.vigencia }}</td>
            <td>{{ f.axodsd }}/{{ f.mesdsd }}</td>
            <td>{{ f.axohst }}/{{ f.meshst }}</td>
            <td>{{ f.FPago }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'PadronConveniosPage',
  data() {
    return {
      filtros: {
        tipo: '',
        subtipo: '',
        vigencia: '0',
        recaudadora: '',
        anio_desde: new Date().getFullYear(),
        anio_hasta: new Date().getFullYear()
      },
      tipos: [],
      subtipos: [],
      vigencias: [],
      recaudadoras: [],
      convenios: [],
      folios: [],
      loading: false,
      error: ''
    };
  },
  created() {
    this.cargarCatalogos();
  },
  methods: {
    async cargarCatalogos() {
      try {
        let [tipos, vigencias, recaudadoras] = await Promise.all([
          this.api('getTipos'),
          this.api('getVigencias'),
          this.api('getRecaudadoras')
        ]);
        this.tipos = tipos;
        this.vigencias = vigencias;
        this.recaudadoras = recaudadoras;
      } catch (e) {
        this.error = 'Error cargando catálogos';
      }
    },
    async onTipoChange() {
      this.filtros.subtipo = '';
      if (this.filtros.tipo) {
        this.subtipos = await this.api('getSubtipos', { tipo: this.filtros.tipo });
      } else {
        this.subtipos = [];
      }
    },
    async buscarConvenios() {
      this.loading = true;
      this.error = '';
      this.convenios = [];
      this.folios = [];
      try {
        let params = { ...this.filtros };
        let data = await this.api('getPadronConvenios', params);
        this.convenios = data;
      } catch (e) {
        this.error = e.message || 'Error consultando convenios';
      } finally {
        this.loading = false;
      }
    },
    async verFolios(conv) {
      this.folios = [];
      try {
        let params = {
          id_conv_resto: conv.id_conv_resto,
          modulo: this.getModulo(conv.tipo, conv.subtipo),
          id_referencia: conv.id_referencia,
          fecha_inicio: conv.fecha_inicio,
          fecha_venc: conv.fecha_venc
        };
        let data = await this.api('getPadronConveniosFolios', params);
        this.folios = data;
      } catch (e) {
        this.error = e.message || 'Error consultando folios';
      }
    },
    getModulo(tipo, subtipo) {
      // Lógica de mapeo de módulo
      if (tipo == 1) return 5;
      if (tipo == 3) {
        if (subtipo == 1) return 9;
        if (subtipo == 2) return 10;
      }
      if (tipo == 6) {
        if (subtipo == 1) return 11;
      }
      if (tipo == 8) return 3;
      if (tipo == 13) return 16;
      return 0;
    },
    async api(action, params = {}) {
      let res = await axios.post('/api/execute', {
        eRequest: { action, params }
      });
      if (res.data && res.data.eResponse && res.data.eResponse.success) {
        return res.data.eResponse.data;
      } else {
        throw new Error(res.data.eResponse.message || 'Error API');
      }
    },
    exportarExcel() {
      // Exportar tabla a Excel usando SheetJS o similar
      // Aquí solo ejemplo básico
      let csv = '';
      let headers = ['ID','Tipo','Subtipo','Expediente','Fecha Inicio','Fecha Venc.','Costo','Descripción','Vigencia','Referencia','Folios'];
      csv += headers.join(',') + '\n';
      this.convenios.forEach(conv => {
        csv += [conv.id_conv_resto, conv.tipo, conv.subtipo, `${conv.letras_exp}/${conv.numero_exp}/${conv.axo_exp}`,
          conv.fecha_inicio, conv.fecha_venc, conv.costo, conv.desc_subtipo, conv.vigencia, conv.referencia, conv.folios].join(',') + '\n';
      });
      let blob = new Blob([csv], { type: 'text/csv' });
      let url = window.URL.createObjectURL(blob);
      let a = document.createElement('a');
      a.href = url;
      a.download = 'padron_convenios.csv';
      a.click();
      window.URL.revokeObjectURL(url);
    }
  },
  filters: {
    fecha(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    },
    moneda(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
};
</script>

<style scoped>
.padron-convenios-page {
  padding: 2rem;
}
.breadcrumb {
  background: #f8f9fa;
}
</style>
